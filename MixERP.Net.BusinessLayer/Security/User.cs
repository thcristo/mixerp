/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Data;

namespace MixERP.Net.BusinessLayer.Security
{
    public static class User
    {
        public static void SetSession(System.Web.UI.Page page, string user)
        {
            if(page != null)
            {
                try
                {
                    using(DataTable table = GetUserTable(user))
                    {
                        if(table.Rows.Count.Equals(1))
                        {
                            long LogOnId = MixERP.Net.Common.Conversion.TryCastLong(table.Rows[0]["login_id"]);

                            if(LogOnId.Equals(0))
                            {
                                MixERP.Net.BusinessLayer.BasePageClass.RequestLogOnPage();
                                return;
                            }

                            page.Session["LogOnId"] = LogOnId;
                            page.Session["UserId"] = table.Rows[0]["user_id"];
                            page.Session["UserName"] = user;
                            page.Session["Role"] = table.Rows[0]["role"];
                            page.Session["IsSystem"] = table.Rows[0]["is_system"];
                            page.Session["IsAdmin"] = table.Rows[0]["is_admin"];
                            page.Session["OfficeCode"] = table.Rows[0]["office_code"];
                            page.Session["OfficeId"] = table.Rows[0]["office_id"];
                            page.Session["NickName"] = table.Rows[0]["nick_name"];
                            page.Session["OfficeName"] = table.Rows[0]["office_name"];
                            page.Session["RegistrationDate"] = table.Rows[0]["registration_date"];
                            page.Session["RegistrationNumber"] = table.Rows[0]["registration_number"];
                            page.Session["PanNumber"] = table.Rows[0]["pan_number"];
                            page.Session["Street"] = table.Rows[0]["street"];
                            page.Session["City"] = table.Rows[0]["city"];
                            page.Session["State"] = table.Rows[0]["state"];
                            page.Session["Country"] = table.Rows[0]["country"];
                            page.Session["ZipCode"] = table.Rows[0]["zip_code"];
                            page.Session["Phone"] = table.Rows[0]["phone"];
                            page.Session["Fax"] = table.Rows[0]["fax"];
                            page.Session["Email"] = table.Rows[0]["email"];
                            page.Session["Url"] = table.Rows[0]["url"];
                        }
                    }
                }
                catch(DbException)
                {
                    //Swallow the exception
                }
            }
        }

        public static bool SignIn(int officeId, string userName, string password, bool remember, System.Web.UI.Page page)
        {
            if(page != null)
            {
                try
                {
                    long LogOnId = MixERP.Net.DatabaseLayer.Security.User.SignIn(officeId, userName, MixERP.Net.Common.Conversion.HashSha512(password, userName), page.Request.UserAgent, "0", "");

                    if(LogOnId > 0)
                    {
                        SetSession(page, userName);

                        FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, userName, DateTime.Now, DateTime.Now.AddMinutes(30), remember, String.Empty, FormsAuthentication.FormsCookiePath);
                        string encryptedCookie = FormsAuthentication.Encrypt(ticket);
                        HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedCookie);
                        cookie.Expires = DateTime.Now.AddMinutes(30);
                        page.Response.Cookies.Add(cookie);
                        //FormsAuthentication.RedirectFromLoginPage(userName, false);

                        System.Web.Security.FormsAuthentication.RedirectFromLoginPage(userName, true, "MixERP.Net");


                        return true;
                    }
                }
                catch(DbException)
                {
                    //Swallow the exception
                }
            }

            return false;
        }

        public static DataTable GetUserTable(string userName)
        {
            return MixERP.Net.DatabaseLayer.Security.User.GetUserTable(userName);
        }

    }
}
