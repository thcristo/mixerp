/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using AjaxControlToolkit;

namespace MixERP.Net.FrontEnd.Services
{
    /// <summary>
    /// Summary description for AccountData
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    [ScriptService]
    public class AccountData : System.Web.Services.WebService
    {
        [WebMethod(EnableSession=true)]
        public CascadingDropDownNameValue[] GetAccounts(string knownCategoryValues, string category)
        {
            if(MixERP.Net.Common.Helpers.Switches.AllowParentAccountInGLTransaction())
            {
                if(MixERP.Net.BusinessLayer.Helpers.SessionHelper.IsAdmin())
                {
                    using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "accounts"))
                    {
                        return this.GetValues(table);
                    }
                }
                else
                {
                    using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "accounts", "confidential", "0"))
                    {
                        return this.GetValues(table);
                    }
                }
            }
            else
            {
                if(MixERP.Net.BusinessLayer.Helpers.SessionHelper.IsAdmin())
                {
                    using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "account_view", "has_child", "0"))
                    {
                        return this.GetValues(table);
                    }
                }
                else
                {
                    {
                        using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "account_view", "has_child, confidential", "0, 0"))
                        {
                            return this.GetValues(table);
                        }
                    }
                }
            }

        }

        private CascadingDropDownNameValue[] GetValues(System.Data.DataTable table)
        {
            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            foreach(System.Data.DataRow dr in table.Rows)
            {
                values.Add(new CascadingDropDownNameValue(dr["account_name"].ToString(), dr["account_code"].ToString()));
            }

            return values.ToArray();
        }

        [WebMethod]
        public CascadingDropDownNameValue[] GetCashRepositories(string knownCategoryValues, string category)
        {
            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);
            string accountCode = kv["Account"];

            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            if(MixERP.Net.BusinessLayer.Core.Accounts.IsCashAccount(accountCode))
            {
                using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("office", "cash_repositories"))
                {
                    foreach(System.Data.DataRow dr in table.Rows)
                    {
                        values.Add(new CascadingDropDownNameValue(dr["cash_repository_name"].ToString(), dr["cash_repository_code"].ToString()));
                    }
                }
            }

            return values.ToArray();

        }
    }
}
