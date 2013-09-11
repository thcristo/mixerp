/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Text;
using Npgsql;

namespace MixERP.Net.DatabaseLayer.Security
{
    public static class User
    {

        public static long SignIn(int officeId, string userName, string password, string browser, string ipAddress, string remoteUser)
        {
            string sql = "SELECT * FROM office.sign_in(@OfficeId, @UserName, @Password, @Browser, @IPAddress, @RemoteUser);";
            using (NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@OfficeId", officeId);
                command.Parameters.AddWithValue("@UserName", userName);
                command.Parameters.AddWithValue("@Password", password);
                command.Parameters.AddWithValue("@Browser", browser);
                command.Parameters.AddWithValue("@IPAddress", ipAddress);
                command.Parameters.AddWithValue("@RemoteUser", remoteUser);

                return MixERP.Net.Common.Conversion.TryCastLong(MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetScalarValue(command));
            }
        }

        public static DataTable GetUserTable(string userName)
        {
            string sql = "SELECT * FROM office.login_view WHERE user_name=@UserName;";
            using (NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@UserName", userName);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }
    }
}
