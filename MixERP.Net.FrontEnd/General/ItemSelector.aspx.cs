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
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.General
{
    public partial class ItemSelector : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void FilterDropDownList_DataBound(object sender, EventArgs e)
        {
            foreach(ListItem item in FilterDropDownList.Items)
            {
                item.Text = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", item.Text);
            }
        }

        protected void SearchGridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if(e.Row.RowType == DataControlRowType.Header)
            {
                for(int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string cellText = e.Row.Cells[i].Text;
                    if(!string.IsNullOrWhiteSpace(cellText))
                    {
                        cellText = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", cellText);
                        e.Row.Cells[i].Text = cellText;
                    }
                }
            }
        }

        protected void Page_Init(object sender, EventArgs e)
        {
            this.LoadParmeters();
            this.LoadGridView();
        }

        private string GetSchema()
        {
            return MixERP.Net.Common.Conversion.TryCastString(this.Request["Schema"]);
        }

        private string GetView()
        {
            return MixERP.Net.Common.Conversion.TryCastString(this.Request["View"]);
        }

        protected void GoButton_Click(object sender, EventArgs e)
        {
            if(string.IsNullOrWhiteSpace(this.GetSchema())) return;
            if(string.IsNullOrWhiteSpace(this.GetView())) return;

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable(this.GetSchema(), this.GetView(), FilterDropDownList.SelectedItem.Value, FilterTextBox.Text, 10))
            {
                SearchGridView.DataSource = table;
                SearchGridView.DataBind();
            }
        }

        private void LoadParmeters()
        {
            if(string.IsNullOrWhiteSpace(this.GetSchema())) return;
            if(string.IsNullOrWhiteSpace(this.GetView())) return;

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.TableHelper.GetTable(this.GetSchema(), this.GetView(), ""))
            {
                FilterDropDownList.DataSource = table;
                FilterDropDownList.DataBind();
            }
        }

        private void LoadGridView()
        {
            if(string.IsNullOrWhiteSpace(this.GetSchema())) return;
            if(string.IsNullOrWhiteSpace(this.GetView())) return;

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable(this.GetSchema(), this.GetView(), "", "", 10))
            {
                SearchGridView.DataSource = table;
                SearchGridView.DataBind();
            }
        }
    }
}