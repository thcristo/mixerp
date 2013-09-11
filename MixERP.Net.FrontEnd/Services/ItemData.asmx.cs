/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.ComponentModel;
using AjaxControlToolkit;
using System.Collections.Specialized;

namespace MixERP.Net.FrontEnd.Services
{
    /// <summary>
    /// Summary description for ItemData
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [ScriptService]
    public class ItemData : System.Web.Services.WebService
    {

        [WebMethod]
        public CascadingDropDownNameValue[] GetItems(string knownCategoryValues, string category)
        {
            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "items"))
            {
                foreach(System.Data.DataRow dr in table.Rows)
                {
                    values.Add(new CascadingDropDownNameValue(dr["item_name"].ToString(), dr["item_code"].ToString()));
                }

                return values.ToArray();
            }
        }

        [WebMethod]
        public CascadingDropDownNameValue[] GetStockItems(string knownCategoryValues, string category)
        {
            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "items", "maintain_stock", "true"))
            {
                foreach(System.Data.DataRow dr in table.Rows)
                {
                    values.Add(new CascadingDropDownNameValue(dr["item_name"].ToString(), dr["item_code"].ToString()));
                }

                return values.ToArray();
            }
        }

        [WebMethod]
        public CascadingDropDownNameValue[] GetUnits(string knownCategoryValues, string category)
        {
            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);            
            string itemCode = kv["Item"];

            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            using (System.Data.DataTable table = MixERP.Net.BusinessLayer.Core.Units.GetUnitViewByItemCode(itemCode))
            {
                foreach (System.Data.DataRow dr in table.Rows)
                {
                    values.Add(new CascadingDropDownNameValue(dr["unit_name"].ToString(), dr["unit_id"].ToString()));
                }

                return values.ToArray();
            }
        }

    }
}
