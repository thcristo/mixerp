/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Npgsql;
using System.Data;
using System.IO;
using System.Data.Common;

namespace MixERP.Net.DatabaseLayer.Helpers
{
    public static class FormHelper
    {
        public static DataTable GetView(string tableSchema, string tableName, string orderBy, int limit, int offset)
        {
            string sql = "SELECT * FROM @TableSchema.@TableName ORDER BY @OrderBy LIMIT @Limit OFFSET @Offset;";

            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                //We are 100% sure that the following parameters do not come from user input.
                //Having said that, it is nice to sanitize the objects before sending it to the database server.
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));
                sql = sql.Replace("@OrderBy", DBFactory.Sanitizer.SanitizeIdentifierName(orderBy));
                sql = sql.Replace("@Limit", MixERP.Net.Common.Conversion.TryCastString(limit));
                sql = sql.Replace("@Offset", MixERP.Net.Common.Conversion.TryCastString(offset));
                command.CommandText = sql;

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

        public static DataTable GetTable(string tableSchema, string tableName)
        {
            string sql = "SELECT * FROM @TableSchema.@TableName;";
            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));
                command.CommandText = sql;

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

        public static DataTable GetTable(string tableSchema, string tableName, string columnNames, string columnValues)
        {
            if(string.IsNullOrWhiteSpace(columnNames))
            {
                return null;
            }

            if(string.IsNullOrWhiteSpace(columnValues))
            {
                return null;
            }

            string[] columns = columnNames.Split(',');
            string[] values = columnValues.Split(',');

            if(!columns.Count().Equals(values.Count()))
            {
                return null;
            }

            int counter = 0;
            string sql = "SELECT * FROM @TableSchema.@TableName WHERE ";

            foreach(string column in columns)
            {
                if(!counter.Equals(0))
                {
                    sql += " AND ";
                }

                sql += DBFactory.Sanitizer.SanitizeIdentifierName(column.Trim()) + " = @" + DBFactory.Sanitizer.SanitizeIdentifierName(column.Trim());

                counter++;
            }

            sql += ";";

            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));


                command.CommandText = sql;

                counter = 0;
                foreach(string column in columns)
                {
                    command.Parameters.AddWithValue(DBFactory.Sanitizer.SanitizeIdentifierName(column.Trim()), values[counter]);
                    counter++;
                }


                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }


        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public static DataTable GetTable(string tableSchema, string tableName, string columnNames, string columnValuesLike, int limit)
        {
            if(columnNames == null)
            {
                columnNames = string.Empty;
            }

            if(columnValuesLike == null)
            {
                columnValuesLike = string.Empty;
            }
            
            string[] columns = columnNames.Split(',');
            string[] values = columnValuesLike.Split(',');

            if(!columns.Count().Equals(values.Count()))
            {
                return null;
            }

            int counter = 0;
            string sql = "SELECT * FROM @TableSchema.@TableName ";

            foreach(string column in columns)
            {
                if(!string.IsNullOrWhiteSpace(column))
                {
                    if(counter.Equals(0))
                    {
                        sql += " WHERE ";
                    }
                    else
                    {
                        sql += " AND ";
                    }

                    sql += " lower(" + DBFactory.Sanitizer.SanitizeIdentifierName(column.Trim()) + "::text) LIKE @" + DBFactory.Sanitizer.SanitizeIdentifierName(column.Trim());
                    counter++;
                }
            }

            sql += " LIMIT @Limit;";

            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));


                command.CommandText = sql;

                counter = 0;
                foreach(string column in columns)
                {
                    if(!string.IsNullOrWhiteSpace(column))
                    {
                        command.Parameters.AddWithValue(DBFactory.Sanitizer.SanitizeIdentifierName(column.Trim()), "%" + values[counter].ToLower(System.Threading.Thread.CurrentThread.CurrentCulture) + "%");
                        counter++;
                    }
                }

                command.Parameters.AddWithValue("@Limit", limit);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }


        public static int GetTotalRecords(string tableSchema, string tableName)
        {
            string sql = "SELECT COUNT(*) FROM @TableSchema.@TableName";
            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));

                command.CommandText = sql;

                return MixERP.Net.Common.Conversion.TryCastInteger(MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetScalarValue(command));
            }
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2202:Do not dispose objects multiple times"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public static bool InsertRecord(int userId, string tableSchema, string tableName, System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> data, string imageColumn)
        {
            if(data == null)
            {
                return false;
            }

            string columns = string.Empty;
            string columnParamters = string.Empty;

            int counter = 0;

            foreach(KeyValuePair<string, string> pair in data)
            {
                counter++;

                if(counter.Equals(1))
                {
                    columns += DBFactory.Sanitizer.SanitizeIdentifierName(pair.Key);
                    columnParamters += "@" + pair.Key;
                }
                else
                {
                    columns += ", " + DBFactory.Sanitizer.SanitizeIdentifierName(pair.Key);
                    columnParamters += ", @" + pair.Key;
                }
            }

            string sql = "INSERT INTO @TableSchema.@TableName(" + columns + ", audit_user_id) SELECT " + columnParamters + ", @AuditUserId;";
            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));

                command.CommandText = sql;

                foreach(KeyValuePair<string, string> pair in data)
                {
                    if(string.IsNullOrWhiteSpace(pair.Value))
                    {
                        command.Parameters.AddWithValue("@" + pair.Key, DBNull.Value);
                    }
                    else
                    {
                        if(pair.Key.Equals(imageColumn))
                        {
                            using(FileStream stream = new FileStream(pair.Value, FileMode.Open, FileAccess.Read))
                            {
                                using(BinaryReader reader = new BinaryReader(new BufferedStream(stream)))
                                {
                                    byte[] byteArray = reader.ReadBytes(Convert.ToInt32(stream.Length));
                                    command.Parameters.AddWithValue("@" + pair.Key, byteArray);
                                }
                            }
                        }
                        else
                        {
                            command.Parameters.AddWithValue("@" + pair.Key, pair.Value);
                        }
                    }
                }

                command.Parameters.AddWithValue("@AuditUserId", userId);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.ExecuteNonQuery(command);
            }
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public static bool UpdateRecord(int userId, string tableSchema, string tableName, System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> data, string keyColumn, string keyColumnValue, string imageColumn)
        {
            if(data == null)
            {
                return false;
            }

            string columns = string.Empty;

            int counter = 0;
            
            //Adding the current user to the column collection.
            KeyValuePair<string, string> auditUserId = new KeyValuePair<string, string>("audit_user_id", userId.ToString(System.Threading.Thread.CurrentThread.CurrentCulture));
            data.Add(auditUserId);

            foreach(KeyValuePair<string, string> pair in data)
            {
                counter++;

                if(counter.Equals(1))
                {
                    columns += DBFactory.Sanitizer.SanitizeIdentifierName(pair.Key) + "=@" + pair.Key;
                }
                else
                {
                    columns += ", " + DBFactory.Sanitizer.SanitizeIdentifierName(pair.Key) + "=@" + pair.Key;
                }
            }

            string sql = "UPDATE @TableSchema.@TableName SET " + columns + " WHERE @KeyColumn=@KeyValue;";

            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));
                sql = sql.Replace("@KeyColumn", DBFactory.Sanitizer.SanitizeIdentifierName(keyColumn));

                command.CommandText = sql;

                foreach(KeyValuePair<string, string> pair in data)
                {
                    if(string.IsNullOrWhiteSpace(pair.Value))
                    {
                        command.Parameters.AddWithValue("@" + pair.Key, DBNull.Value);
                    }
                    else
                    {
                        if(pair.Key.Equals(imageColumn))
                        {
                            using(FileStream stream = new FileStream(pair.Value, FileMode.Open, FileAccess.Read))
                            {
                                using(BinaryReader reader = new BinaryReader(new BufferedStream(stream)))
                                {
                                    byte[] byteArray = reader.ReadBytes(Convert.ToInt32(stream.Length));
                                    command.Parameters.AddWithValue("@" + pair.Key, byteArray);
                                }
                            }
                        }
                        else
                        {
                            command.Parameters.AddWithValue("@" + pair.Key, pair.Value);
                        }
                    }
                }

                command.Parameters.AddWithValue("@KeyValue", keyColumnValue);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.ExecuteNonQuery(command);
            }
        }

        public static bool DeleteRecord(string tableSchema, string tableName, string keyColumn, string keyColumnValue)
        {
            string sql = "DELETE FROM @TableSchema.@TableName WHERE @KeyColumn=@KeyValue";

            using(NpgsqlCommand command = new NpgsqlCommand())
            {
                sql = sql.Replace("@TableSchema", DBFactory.Sanitizer.SanitizeIdentifierName(tableSchema));
                sql = sql.Replace("@TableName", DBFactory.Sanitizer.SanitizeIdentifierName(tableName));
                sql = sql.Replace("@KeyColumn", DBFactory.Sanitizer.SanitizeIdentifierName(keyColumn));
                command.CommandText = sql;

                command.Parameters.AddWithValue("@KeyValue", keyColumnValue);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.ExecuteNonQuery(command);
            }
        }
    }
}
