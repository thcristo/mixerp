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
    public static class Units
    {
        public static DataTable GetUnitViewByItemCode(string itemCode)
        {
            string sql = "SELECT * FROM core.get_associated_units_from_item_code(@ItemCode);";
            using (NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@ItemCode", itemCode);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

        public static bool UnitExistsByName(string unitName)
        {
            string sql = "SELECT 1 FROM core.units WHERE core.units.unit_name=@UnitName;";
            using (NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@UnitName", unitName);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetScalarValue(command).ToString().Equals("1");
            }        
        }
    }
}
