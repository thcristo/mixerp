/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace MixERP.Net.Common.Helpers
{
    public static class LocalizationHelper
    {
        public static string GetResourceString(string className, string key)
        {
            if(string.IsNullOrWhiteSpace(key) || System.Web.HttpContext.Current == null)
            {
                return string.Empty;
            }
            try
            {
                return System.Web.HttpContext.GetGlobalResourceObject(className, key, Culture()).ToString();
            }
            catch
            {
                throw new InvalidOperationException("Resource could not be found for the key " + key + " on class " + className + " .");
            }
        }

        public static string GetResourceString(string className, string key, bool throwError)
        {
            if(string.IsNullOrWhiteSpace(key) || System.Web.HttpContext.Current == null)
            {
                return string.Empty;
            }
            try
            {
                return System.Web.HttpContext.GetGlobalResourceObject(className, key, Culture()).ToString();
            }
            catch
            {
                if(throwError)
                {
                    throw new InvalidOperationException("Resource could not be found for the key " + key + " on class " + className + " .");
                }
            }

            return key;
        }


        public static CultureInfo Culture()
        {
            //Todo
            CultureInfo culture = new CultureInfo(CultureInfo.InvariantCulture.Name);
            return culture;
        }

    }
}
