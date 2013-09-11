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

namespace MixERP.Net.BusinessLayer.Core
{
    public static class Units
    {
        public static DataTable GetUnitViewByItemCode(string itemCode)
        {
            return MixERP.Net.DatabaseLayer.Core.Units.GetUnitViewByItemCode(itemCode);
        }

        public static bool UnitExistsByName(string unitName)
        {
            return MixERP.Net.DatabaseLayer.Core.Units.UnitExistsByName(unitName);
        }

        public static string GetDisplayField()
        {
            string displayField = MixERP.Net.Common.Helpers.ConfigurationHelper.GetSectionKey("MixERPDbParameters", "UnitDisplayField");

            if(string.IsNullOrWhiteSpace(displayField))
            {
                displayField = "unit_name";
            }

            return displayField;
        }

    }
}
