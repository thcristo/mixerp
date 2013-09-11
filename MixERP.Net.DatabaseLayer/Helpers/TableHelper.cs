/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Npgsql;

namespace MixERP.Net.DatabaseLayer.Helpers
{
    public static class TableHelper
    {
        public static DataTable GetTable(string schema, string tableName, string exclusion)
        {
            string sql = string.Empty;
            
            if (!string.IsNullOrWhiteSpace(exclusion))
            {
                string[] exclusions = exclusion.Split(',');
                string[] paramNames = exclusions.Select((s, i) => "@Paramter" + i.ToString(System.Threading.Thread.CurrentThread.CurrentCulture).Trim()).ToArray();
                string inClause = string.Join(",", paramNames);

                sql= string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "select * from core.mixerp_table_view where table_schema=@Schema AND table_name=@TableName AND column_name NOT IN({0});", inClause);

                using (NpgsqlCommand command = new NpgsqlCommand(sql))
                {
                    command.Parameters.AddWithValue("@Schema", schema);
                    command.Parameters.AddWithValue("@TableName", tableName);

                    for (int i = 0; i < paramNames.Length; i++)
                    {
                        command.Parameters.AddWithValue(paramNames[i], exclusions[i].Trim());
                    }

                    return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
                }
            }
            else
            {
                sql = "select * from core.mixerp_table_view where table_schema=@Schema AND table_name=@TableName;";

                using (NpgsqlCommand command = new NpgsqlCommand(sql))
                {
                    command.Parameters.AddWithValue("@Schema", schema);
                    command.Parameters.AddWithValue("@TableName", tableName);

                    return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
                }
            
            }
        }

    }
}
