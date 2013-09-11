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

namespace MixERP.Net.DatabaseLayer.Office
{
    public static class CashRepositories
    {
        public static DataTable GetCashRepositories()
        {
            string sql = "SELECT * FROM office.cash_repositories;";
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

        public static DataTable GetCashRepositories(int officeId)
        {
            string sql = "SELECT * FROM office.cash_repositories WHERE office_id=@OfficeId;";
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@OfficeId", officeId);
                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

        public static decimal GetBalance(int cashRepositoryId)
        {
            string sql = "SELECT transactions.get_cash_repository_balance(@CashRepositoryId);";
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@CashRepositoryId", cashRepositoryId);
                return MixERP.Net.Common.Conversion.TryCastDecimal(MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetScalarValue(command));
            }
        }

    }
}
