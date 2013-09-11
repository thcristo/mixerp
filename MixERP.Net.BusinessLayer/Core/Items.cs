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

namespace MixERP.Net.BusinessLayer.Core
{
    public static class Items
    {
        public static bool ItemExistsByCode(string itemCode)
        {
            return MixERP.Net.DatabaseLayer.Core.Items.ItemExistsByCode(itemCode);
        }

        public static decimal GetItemSellingPrice(string itemCode, string partyCode, int priceTypeId, int unitId)
        {
            return MixERP.Net.DatabaseLayer.Core.Items.GetItemSellingPrice(itemCode, partyCode, priceTypeId, unitId);
        }

        public static decimal GetItemCostPrice(string itemCode, string partyCode, int unitId)
        {
            return MixERP.Net.DatabaseLayer.Core.Items.GetItemCostPrice(itemCode, partyCode, unitId);
        }

        public static decimal GetTaxRate(string itemCode)
        {
            return MixERP.Net.DatabaseLayer.Core.Items.GetTaxRate(itemCode);
        }

        public static decimal CountItemInStock(string itemCode, int unitId, int storeId)
        {
            return MixERP.Net.DatabaseLayer.Core.Items.CountItemInStock(itemCode, unitId, storeId);
        }

        public static bool IsStockItem(string itemCode)
        {
            return MixERP.Net.DatabaseLayer.Core.Items.IsStockItem(itemCode);
        }
    }
}
