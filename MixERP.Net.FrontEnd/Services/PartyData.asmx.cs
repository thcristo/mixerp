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
    /// Summary description for PartyData
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    [ScriptService]
    public class PartyData : System.Web.Services.WebService
    {

        [WebMethod(EnableSession = true)]
        public CascadingDropDownNameValue[] GetParties(string knownCategoryValues, string category)
        {
            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable("core", "parties"))
            {
                table.Columns.Add("party", typeof(string), MixERP.Net.BusinessLayer.Core.Parties.GetDisplayField());
                return this.GetValues(table);
            }

        }

        private CascadingDropDownNameValue[] GetValues(System.Data.DataTable table)
        {
            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            foreach(System.Data.DataRow dr in table.Rows)
            {
                values.Add(new CascadingDropDownNameValue(dr["party"].ToString(), dr["party_code"].ToString()));
            }

            return values.ToArray();
        }

        [WebMethod]
        public CascadingDropDownNameValue[] GetShippingAddresses(string knownCategoryValues, string category)
        {
            System.Collections.ObjectModel.Collection<CascadingDropDownNameValue> values = new System.Collections.ObjectModel.Collection<CascadingDropDownNameValue>();

            StringDictionary kv = CascadingDropDown.ParseKnownCategoryValuesString(knownCategoryValues);
            string partyCode = kv["Party"];

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Core.ShippingAddresses.GetShippingAddressView(partyCode))
            {
                table.Columns.Add("shipping_address", typeof(string), MixERP.Net.BusinessLayer.Core.ShippingAddresses.GetDisplayField());

                foreach(System.Data.DataRow dr in table.Rows)
                {
                    values.Add(new CascadingDropDownNameValue(dr["shipping_address_code"].ToString(), dr["shipping_address"].ToString()));
                }
            }

            return values.ToArray();

        }


    }
}
