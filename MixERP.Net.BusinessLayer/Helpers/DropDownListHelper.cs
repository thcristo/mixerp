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
using System.Web.UI.WebControls;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class DropDownListHelper
    {
        public static void BindDropDownList(ListControl list, string schemaName, string tableName, string valueField, string displayField)
        {
            if(list == null)
            {
                return;
            }
            
            using(DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable(schemaName, tableName))
            {
                table.Columns.Add("text_field", typeof(string), displayField);

                list.DataSource = table;
                list.DataValueField = valueField;
                list.DataTextField = "text_field";
                list.DataBind();
            }
        }

        public static void BindDropDownList(ListControl list, DataTable table, string valueField, string displayField)
        {
            if(list == null)
            {
                return;
            }

            if(table == null)
            {
                return;
            }
            
            table.Columns.Add("text_field", typeof(string), displayField);

            list.DataSource = table;
            list.DataValueField = valueField;
            list.DataTextField = "text_field";
            list.DataBind();
        }

        /// <summary>
        /// Selects the item in the list control that contains the specified value, if it exists.
        /// </summary>
        /// <param name="dropDownList"></param>
        /// <param name="selectedValue">The value of the item in the list control to select</param>
        /// <returns>Returns true if the value exists in the list control, false otherwise</returns>
        public static bool SetSelectedValue(DropDownList dropDownList, String selectedValue)
        {
            dropDownList.ClearSelection();

            ListItem selectedListItem = dropDownList.Items.FindByValue(selectedValue);

            if(selectedListItem != null)
            {
                selectedListItem.Selected = true;
                return true;
            }
            else
            {
                return false;
            }
        }
    }
}
