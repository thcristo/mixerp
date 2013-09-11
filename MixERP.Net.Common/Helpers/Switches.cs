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

namespace MixERP.Net.Common.Helpers
{
    public static class Switches
    {
        public static bool AllowNonSupplierInPurchase()
        {
            return GetSwitch("AllowNonSupplierInPurchase");
        }

        public static bool AllowSupplierInSales()
        {
            return GetSwitch("AllowSupplierInSales");
        }

        public static bool AllowParentAccountInGLTransaction()
        {
            return GetSwitch("AllowParentAccountInGLTransaction");        
        }

        public static bool EnableAutoVerification()
        {
            return GetSwitch("EnableAutoVerification");                
        }

        public static bool TaxAfterDiscount()
        {
            return GetSwitch("TaxAfterDiscount");
        }

        private static bool GetSwitch(string key)
        {
            string sw = MixERP.Net.Common.Helpers.ConfigurationHelper.GetSectionKey("MixERPSwitches", key);
            if(string.IsNullOrWhiteSpace(sw))
            {
                return false;
            }

            return sw.Equals("true");
        }

    }
}
