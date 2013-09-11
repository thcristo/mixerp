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
    public static class ShippingAddresses
    {
        public static DataTable GetShippingAddressView(int partyId)
        {
            return MixERP.Net.DatabaseLayer.Core.ShippingAddresses.GetShippingAddressView(partyId);
        }

        public static DataTable GetShippingAddressView(string partyCode)
        {
            return MixERP.Net.DatabaseLayer.Core.ShippingAddresses.GetShippingAddressView(partyCode);
        }

        public static string GetDisplayField()
        {
            string displayField = MixERP.Net.Common.Helpers.ConfigurationHelper.GetSectionKey("MixERPDbParameters", "ShippingAddressDisplayField");

            if(string.IsNullOrWhiteSpace(displayField))
            {
                displayField = "city";
            }

            return displayField;
        }

    }
}
