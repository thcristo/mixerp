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

namespace MixERP.Net.FrontEnd.Reports
{
    public partial class ReportViewer : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void Page_Init(object sender, EventArgs e)
        {
            this.AddParameters();
        }

        private void AddParameters()
        {
            System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> collection = this.GetParameters();

            if(collection == null || collection.Count.Equals(0))
            {
                ReportParameterPanel.Style.Add("display", "none");
                ReportViewer1.Path = this.ReportPath();
                ReportViewer1.InitializeReport();
                return;
            }

            foreach(KeyValuePair<string, string> parameter in collection)
            {
                TextBox textBox = new TextBox();
                textBox.ID = parameter.Key.Replace("@", "") + "_text_box";

                string label = "<label for='" + textBox.ID + "'>" + MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", parameter.Key.Replace("@", "")) + "</label>";

                if(parameter.Value.Equals("Date"))
                {

                }
                else
                {

                }

                AddRow(label, textBox);
            }

            Button button = new Button();
            button.ID = "UpdateButton";
            button.Text = Resources.Titles.Update;
            button.CssClass = "myButton";
            button.Click += button_Click;

            AddRow("", button);

        }

        protected void button_Click(object sender, EventArgs e)
        {
            if(ReportParameterTable.Rows.Count.Equals(0))
            {
                return;
            }

            System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> list = new System.Collections.ObjectModel.Collection<KeyValuePair<string, string>>();

            foreach(TableRow row in ReportParameterTable.Rows)
            {
                TableCell cell = row.Cells[1];

                if(cell.Controls[0] is TextBox)
                {
                    TextBox textBox = (TextBox)cell.Controls[0];
                    list.Add(new KeyValuePair<string, string>("@" + textBox.ID.Replace("_text_box", ""), textBox.Text));
                }
            }
            ReportViewer1.Path = this.ReportPath();
            ReportViewer1.ParameterCollection = MixERP.Net.BusinessLayer.Helpers.ReportHelper.BindParameters(Server.MapPath(this.ReportPath()), list);
            ReportViewer1.InitializeReport();
        }

        private void AddRow(string label, Control control)
        {
            TableRow row = new TableRow();

            TableCell cell = new TableCell();
            cell.Text = label;

            TableCell controlCell = new TableCell();
            controlCell.Controls.Add(control);

            row.Cells.Add(cell);
            row.Cells.Add(controlCell);

            ReportParameterTable.Rows.Add(row);

        }

        private string ReportPath()
        {
            string id = this.Request["Id"];
            if(string.IsNullOrWhiteSpace(id))
            {
                return null;
            }

            return "~/Reports/Sources/en-US/" + id;
        }

        private System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> GetParameters()
        {
            string path = Server.MapPath(this.ReportPath());
            System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> collection = MixERP.Net.BusinessLayer.Helpers.ReportHelper.GetParameters(path);
            return collection;
        }
    }
}