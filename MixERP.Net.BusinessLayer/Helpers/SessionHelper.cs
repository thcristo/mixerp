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
using System.Web;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class SessionHelper
    {
        public static long LogOnId()
        {
            return MixERP.Net.Common.Conversion.TryCastLong(HttpContext.Current.Session["LogOnId"]);
        }
        
        public static int UserId()
        {
            return MixERP.Net.Common.Conversion.TryCastInteger(HttpContext.Current.Session["UserId"]);
        }

        public static string UserName()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["UserName"]);
        }

        public static string Role()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Role"]);
        }

        public static bool IsAdmin()
        {
            return MixERP.Net.Common.Conversion.TryCastBoolean(HttpContext.Current.Session["IsAdmin"]);
        }

        public static bool IsSystem()
        {
            return MixERP.Net.Common.Conversion.TryCastBoolean(HttpContext.Current.Session["IsSystem"]);
        }

        public static int OfficeId()
        {
            return MixERP.Net.Common.Conversion.TryCastInteger(HttpContext.Current.Session["OfficeId"]);
        }

        public static string Nickname()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["NickName"]);
        }

        public static string OfficeName()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["OfficeName"]);
        }

        public static DateTime RegistrationDate()
        {
            return MixERP.Net.Common.Conversion.TryCastDate(HttpContext.Current.Session["RegistrationDate"]);
        }

        public static string RegistrationNumber()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["RegistrationNumber"]);
        }

        public static string PanNumber()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["PanNumber"]);
        }

        public static string Street()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Street"]);
        }

        public static string City()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["City"]);
        }

        public static string State()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["State"]);
        }

        public static string Country()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Country"]);
        }

        public static string ZipCode()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["ZipCode"]);
        }

        public static string Phone()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Phone"]);
        }

        public static string Fax()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Fax"]);
        }

        public static string Email()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Email"]);
        }

        public static string Url()
        {
            return MixERP.Net.Common.Conversion.TryCastString(HttpContext.Current.Session["Url"]);
        }

        public static CultureInfo Culture()
        {
            return MixERP.Net.Common.Helpers.LocalizationHelper.Culture();
        }
    }
}
