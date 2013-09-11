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
using System.Web;
using System.Web.UI;
using System.Globalization;
using System.Net;

namespace MixERP.Net.Common
{
    public static class PageUtility
    {
        public static void RefreshPage(System.Web.UI.Page page)
        {
            if(page != null)
            {
                page.Response.Redirect(page.Request.Url.AbsolutePath);
            }
        }

        public static string GetUserIPAddress()
        {
            Page page = HttpContext.Current.Handler as Page;
            string ip = page.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if(!string.IsNullOrEmpty(ip))
            {
                string[] ipRange = ip.Split(',');
                ip = ipRange[0];
            }
            else
            {
                ip = page.Request.ServerVariables["REMOTE_ADDR"];
            }
            return ip.Trim();
        }

        public static void ExecuteJavaScript(string key, string javaScript, Page page)
        {
            ScriptManager.RegisterStartupScript(page, typeof(System.Web.UI.Page), key, javaScript, true);
        }

        public static string ResolveUrl(string relativeUrl)
        {
            if(HttpContext.Current != null)
            {
                System.Web.UI.Page p = HttpContext.Current.Handler as System.Web.UI.Page;
                if(p != null)
                {
                    return p.ResolveUrl(relativeUrl);
                }
            }
            return relativeUrl;
        }

        public static bool IsLocalUrl(Uri url, System.Web.UI.Page page)
        {
            if(page == null)
            {
                return false;
            }

            try
            {
                Uri requested = new Uri(page.Request.Url, url);

                if(requested.Host == page.Request.Url.Host)
                {
                    return true;
                }
            }
            catch(InvalidOperationException)
            {
                //
            }

            return false;
        }

        public static int InvalidPasswordAttempts(System.Web.UI.Page page, int increment)
        {
            if(page == null)
            {
                return 0;
            }

            int retVal = 0;
            if(page.Session["InvalidPasswordAttempts"] == null)
            {
                retVal = retVal + increment;
                page.Session.Add("InvalidPasswordAttempts", retVal);
            }
            else
            {
                retVal = MixERP.Net.Common.Conversion.TryCastInteger(page.Session["InvalidPasswordAttempts"]) + increment;
                page.Session["InvalidPasswordAttempts"] = retVal;
            }

            return retVal;
        }

        public static void CheckInvalidAttempts(System.Web.UI.Page page)
        {
            if(page != null)
            {
                if(MixERP.Net.Common.PageUtility.InvalidPasswordAttempts(page, 0) >= MixERP.Net.Common.Conversion.TryCastInteger(System.Configuration.ConfigurationManager.AppSettings["MaxInvalidPasswordAttempts"]))
                {
                    page.Response.Redirect("~/access-denied");
                }
            }
        }

        public static string GetCurrentDomainName()
        {
            string url = System.Web.HttpContext.Current.Request.Url.Scheme + "://" + System.Web.HttpContext.Current.Request.Url.Host;

            if(System.Web.HttpContext.Current.Request.Url.Port != 80)
            {
                url += ":" + System.Web.HttpContext.Current.Request.Url.Port.ToString(CultureInfo.InvariantCulture);
            }

            return url;
        }

        public static Control FindControlIterative(Control root, string id)
        {
            if(root == null)
            {
                return null;
            }
            
            if(root.ID == id) return root;
            foreach(Control c in root.Controls)
            {
                Control t = FindControlIterative(c, id);
                if(t != null) return t;
            }
            return null;
        }

        /// <summary>
        /// Check if the input is a valid url.
        /// </summary>
        /// <param name="url"></param>
        /// <returns>Returns input if it's a valid url. If the input is not a valid url, returns empty string.</returns>
        public static string CleanUrl(string url)
        {
            if(string.IsNullOrWhiteSpace(url))
            {
                return string.Empty;
            }

            string prefix = "http";

            if(url.Substring(0, prefix.Length) != prefix)
            {
                url = prefix + "://" + url;
            }

            using(var client = new MyClient())
            {
                client.HeadOnly = true;
                try
                {
                    client.DownloadString(url);
                }
                catch(WebException)
                {
                    url = string.Empty;
                }

                return url;
            }

        }

        private class MyClient : WebClient
        {
            public bool HeadOnly { get; set; }

            protected override WebRequest GetWebRequest(Uri address)
            {
                WebRequest req = base.GetWebRequest(address);
                if(HeadOnly && req.Method == "GET")
                {
                    req.Method = "HEAD";
                }
                return req;
            }
        }

    }
}
