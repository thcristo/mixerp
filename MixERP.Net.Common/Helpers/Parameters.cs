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
    public static class Parameters
    {
        public static string PartyName()
        {
            return GetParameter("PartyName");
        }
        
        private static string GetParameter(string key)
        {
            return MixERP.Net.Common.Helpers.ConfigurationHelper.GetSectionKey("MixERPParameters", key);
        }

        public static string ShortDateFormat()
        {
            return GetParameter("ShortDateFormat");
        }

        public static string LongDateFormat()
        {
            return GetParameter("LongDateFormat");
        }

        public static string ShortTimeFormat()
        {
            return GetParameter("ShortTimeFormat");
        }

        public static string LongTimeFormat()
        {
            return GetParameter("LongTimeFormat");
        }

        public static string ThousandSeparator()
        {
            return GetParameter("ThousandSeparator");
        }

        public static string DecimalSeparator()
        {
            return GetParameter("DecimalSeparator");
        }

        public static string DecimalPlaces()
        {
            return GetParameter("DecimalPlaces");
        }

        public static string CurrencySymbol()
        {
            return GetParameter("CurrencySymbol");
        }
    }
}
