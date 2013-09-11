/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using Npgsql;

namespace MixERP.Net.DatabaseLayer.Helpers
{
    public static class ReportHelper
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2100:Review SQL queries for security vulnerabilities")]
        public static DataTable GetDataTable(string sql, System.Collections.ObjectModel.Collection<KeyValuePair<string,string>> parameters)
        {
            if(string.IsNullOrWhiteSpace(sql))
            {
                return null;
            }
            
            
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                if(parameters != null)
                {
                    foreach(KeyValuePair<string, string> p in parameters)
                    {
                        command.Parameters.AddWithValue(p.Key, p.Value);
                    }
                }

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }
    }
}
