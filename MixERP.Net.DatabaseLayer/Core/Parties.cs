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

namespace MixERP.Net.DatabaseLayer.Core
{
    public static class Parties
    {
        public static bool IsCreditAllowed(string partyCode)
        {
            string sql = "SELECT 1 FROM core.parties WHERE party_code=@PartyCode and allow_credit=true;";

            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@PartyCode", partyCode);
                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command).Rows.Count.Equals(1);
            }
        }
    }
}
