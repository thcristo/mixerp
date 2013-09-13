/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Linq;
using MixERP.Net.BusinessLayer.Helpers;

namespace MixERP.Net.FrontEnd.UserControls
{
    public partial class ReportControl : System.Web.UI.UserControl
    {
        private string reportPath;
        #region "Properties"
        public string Path { get; set; }
        public bool AutoInitialize { get; set; }

        /// <summary>
        /// Collection of each datasources' parameter collection.
        /// The datasource parameter collection is a collection of
        /// parameters stored in KeyValuePair.
        /// </summary>
        public Collection<Collection<KeyValuePair<string, string>>> ParameterCollection { get; set; }
        #endregion

        private bool IsValid()
        {
            if(string.IsNullOrWhiteSpace(this.Path))
            {
                return false;
            }

            this.reportPath = Server.MapPath(this.Path);

            if(!System.IO.File.Exists(this.reportPath))
            {
                return false;
            }

            return true;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if(this.AutoInitialize)
            {
                this.InitializeReport();
            }
        }

        public void InitializeReport()
        {
            //Check if the set report path is a valid file.
            if(!this.IsValid())
            {
                ReportTitleLiteral.Text = Resources.Titles.ReportNotFound;
                ReportTitleHidden.Value = ReportTitleLiteral.Text;
                TopSectionLiteral.Text = string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, Resources.Warnings.InvalidLocation, this.reportPath);
                return;
            }

            this.SetDecimalFields();
            this.SetRunningTotalFields();
            this.SetDataSources();
            this.SetTitle();
            this.SetTopSection();
            this.SetBodySection();
            this.SetGridViews();
            this.SetBottomSection();
            this.CleanUp();
        }

        private System.Collections.ObjectModel.Collection<string> DecimalFieldIndicesCollection;
        private void SetDecimalFields()
        {
            string decimalFieldIndices = string.Empty;

            //Get the list of datasources for this report.
            XmlNodeList dataSourceList = XmlHelper.GetNodes(reportPath, "//DataSource");

            //Initializing decimal field indices collection.
            this.DecimalFieldIndicesCollection = new System.Collections.ObjectModel.Collection<string>();

            //Loop through each datasource in the datasource list.
            foreach(XmlNode dataSource in dataSourceList)
            {
                //Resetting the variable for each iteration.
                decimalFieldIndices = string.Empty;

                //Loop through each datasource child node.
                foreach(XmlNode node in dataSource.ChildNodes)
                {
                    //Selecting the nodes matching the tag <DecimalFieldIndices>.
                    if(node.Name.Equals("DecimalFieldIndices"))
                    {
                        decimalFieldIndices = node.InnerText;
                    }
                }

                //Add current "DecimalFieldIndices" to the collection object.
                //If a child node is found which matches the tag <DecimalFieldIncides> 
                //under the current node, the variable "decimalFieldIndices" will have
                //a value. If not, an empty string will be added to the collection.
                this.DecimalFieldIndicesCollection.Add(decimalFieldIndices);
            }        
        }

        private System.Collections.ObjectModel.Collection<int> RunningTotalTextColumnIndexCollection;
        private System.Collections.ObjectModel.Collection<string> RunningTotalFieldIndicesCollection;
        private void SetRunningTotalFields()
        {
            //Get the list of datasources for this report.
            XmlNodeList dataSourceList = XmlHelper.GetNodes(reportPath, "//DataSource");
            int runningTotalTextColumnIndex = 0;
            string runningTotalFieldIndices = string.Empty;

            //Initializing running total text column index collection.
            this.RunningTotalTextColumnIndexCollection = new System.Collections.ObjectModel.Collection<int>();

            //Initializing running total field indices collection.
            this.RunningTotalFieldIndicesCollection = new System.Collections.ObjectModel.Collection<string>();

            //Loop through each datasource in the datasource list.
            foreach(XmlNode dataSource in dataSourceList)
            {
                //Resetting the variables for each iteration.
                runningTotalTextColumnIndex = 0;
                runningTotalFieldIndices = string.Empty;

                //Loop through each datasource child node.
                foreach(XmlNode node in dataSource.ChildNodes)
                {
                    //Selecting the nodes matching the tag <RunningTotalTextColumnIndex>.
                    if(node.Name.Equals("RunningTotalTextColumnIndex"))
                    {
                        runningTotalTextColumnIndex = MixERP.Net.Common.Conversion.TryCastInteger(node.InnerText);
                    }

                    //Selecting the nodes matching the tag <RunningTotalFieldIndices>.
                    if(node.Name.Equals("RunningTotalFieldIndices"))
                    {
                        runningTotalFieldIndices = node.InnerText;
                    }
                }

                //Add current "RunningTotalTextColumnIndexCollection" and "RunningTotalFieldIndicesCollection" 
                //to the collection object.
                //If child nodes are found which match the the associated tags 
                //under the current node, the variable "runningTotalTextColumnIndex" and "runningTotalFieldIndices" will have
                //values. If not, an empty string for "runningTotalFieldIndices" and zero for "runningTotalTextColumnIndex" 
                //will be added to the collection.
                this.RunningTotalTextColumnIndexCollection.Add(runningTotalTextColumnIndex);
                this.RunningTotalFieldIndicesCollection.Add(runningTotalFieldIndices);
            }
        }

        private System.Collections.ObjectModel.Collection<System.Data.DataTable> DataTableCollection;
        private void SetDataSources()
        {
            int index = 0;

            //Get the list of datasources for this report.
            System.Xml.XmlNodeList dataSources = XmlHelper.GetNodes(reportPath, "//DataSource");

            //Initializing data source collection.
            this.DataTableCollection = new System.Collections.ObjectModel.Collection<System.Data.DataTable>();

            //Loop through each datasource in the datasource list.
            foreach(System.Xml.XmlNode datasource in dataSources)
            {
                //Loop through each datasource child node.
                foreach(System.Xml.XmlNode c in datasource.ChildNodes)
                {
                    //Selecting the nodes matching the tag <Query>.
                    if(c.Name.Equals("Query"))
                    {
                        index++;
                        string sql = c.InnerText;

                        //Initializing query parameter collection.
                        Collection<KeyValuePair<string, string>> parameters = new Collection<KeyValuePair<string, string>>();

                        //Check if this report needs has has parameters.
                        if(this.ParameterCollection != null)
                        {
                            //Get the parameter collection for this datasource.
                            parameters = this.ParameterCollection[index - 1];
                        }

                        //Get DataTable from SQL Query and parameter collection.
                        using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.ReportHelper.GetDataTable(sql, parameters))
                        {
                            //Add this datatable to the collection for later binding.
                            this.DataTableCollection.Add(table);
                        }
                    }
                }
            }
        }

        private void SetTitle()
        {
            string title = XmlHelper.GetNodeText(reportPath, "/PesReport/Title");
            ReportTitleLiteral.Text = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseExpression(title);
            ReportTitleHidden.Value = ReportTitleLiteral.Text;

            if(!string.IsNullOrWhiteSpace(ReportTitleLiteral.Text))
            {
                this.Page.Title = ReportTitleLiteral.Text;
            }
        }

        #region "Set Sections"
        private void SetTopSection()
        {
            string topSection = XmlHelper.GetNodeText(reportPath, "/PesReport/TopSection");
            topSection = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseExpression(topSection);
            topSection = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseDataSource(topSection, this.DataTableCollection);
            TopSectionLiteral.Text = topSection;
        }
        private void SetBodySection()
        {
            string bodySection = XmlHelper.GetNodeText(reportPath, "/PesReport/Body/Content");
            bodySection = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseExpression(bodySection);
            bodySection = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseDataSource(bodySection, this.DataTableCollection);
            ContentLiteral.Text = bodySection;
        }
        private void SetBottomSection()
        {
            string bottomSection = XmlHelper.GetNodeText(reportPath, "/PesReport/BottomSection");
            bottomSection = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseExpression(bottomSection);
            bottomSection = MixERP.Net.BusinessLayer.Reporting.ReportParser.ParseDataSource(bottomSection, this.DataTableCollection);
            BottomSectionLiteral.Text = bottomSection;
        }
        #endregion

        private void SetGridViews()
        {
            XmlNodeList gridViewDataSource = XmlHelper.GetNodes(reportPath, "//GridViewDataSource");
            string indices = string.Empty;

            foreach(XmlNode node in gridViewDataSource)
            {
                if(node.Attributes["Index"] != null)
                {
                    indices += node.Attributes["Index"].Value + ",";
                }
            }

            this.LoadGrid(string.Concat(indices));
        }
        private void LoadGrid(string indices)
        {
            foreach(string data in indices.Split(','))
            {
                string ds = data.Trim();

                if(!string.IsNullOrWhiteSpace(ds))
                {
                    //if(!ds.Contains(' '))
                    //{
                    int index = MixERP.Net.Common.Conversion.TryCastInteger(ds);

                    GridView grid = new GridView();
                    grid.EnableTheming = false;

                    grid.ID = "GridView" + ds;
                    grid.CssClass = "report";

                    grid.Width = Unit.Percentage(100);
                    grid.GridLines = GridLines.Both;
                    grid.RowDataBound += GridView_RowDataBound;
                    grid.DataBound += GridView_DataBound;
                    BodyPlaceHolder.Controls.Add(grid);

                    grid.DataSource = this.DataTableCollection[index];
                    grid.DataBind();
                    //}
                }
            }

        }


        #region "GridView Events"
        void GridView_DataBound(object sender, EventArgs e)
        {
            GridView grid = (GridView)sender;

            int arg = MixERP.Net.Common.Conversion.TryCastInteger(grid.ID.Replace("GridView", ""));

            if(string.IsNullOrWhiteSpace(this.RunningTotalFieldIndicesCollection[arg]))
            {
                return;
            }

            if(grid.FooterRow == null)
            {
                return;
            }

            grid.FooterRow.Visible = true;

            for(int i = 0; i < this.RunningTotalTextColumnIndexCollection[arg]; i++)
            {
                grid.FooterRow.Cells[i].Visible = false;
            }

            grid.FooterRow.Cells[this.RunningTotalTextColumnIndexCollection[arg]].ColumnSpan = this.RunningTotalTextColumnIndexCollection[arg] + 1;
            grid.FooterRow.Cells[this.RunningTotalTextColumnIndexCollection[arg]].Text = Resources.Titles.Total;
            grid.FooterRow.Cells[this.RunningTotalTextColumnIndexCollection[arg]].Style.Add("text-align", "right");
            grid.FooterRow.Cells[this.RunningTotalTextColumnIndexCollection[arg]].Font.Bold = true;

            foreach(string field in this.RunningTotalFieldIndicesCollection[arg].Split(','))
            {
                int index = MixERP.Net.Common.Conversion.TryCastInteger(field.Trim());

                decimal total = 0;

                if(index > 0)
                {
                    foreach(GridViewRow row in grid.Rows)
                    {
                        if(row.RowType == DataControlRowType.DataRow)
                        {
                            total += MixERP.Net.Common.Conversion.TryCastDecimal(row.Cells[index].Text);
                        }
                    }

                    grid.FooterRow.Cells[index].Text = string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "{0:N}", total);
                    grid.FooterRow.Cells[index].Font.Bold = true;
                }
            }
        }

        void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if(e.Row.RowType == DataControlRowType.Header)
            {
                for(int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string cellText = e.Row.Cells[i].Text;

                    cellText = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", cellText, false);
                    e.Row.Cells[i].Text = cellText;
                    e.Row.Cells[i].HorizontalAlign = HorizontalAlign.Left;
                }
            }

            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                GridView grid = (GridView)sender;
                int arg = MixERP.Net.Common.Conversion.TryCastInteger(grid.ID.Replace("GridView", ""));

                //Apply formatting on decimal fields
                if(string.IsNullOrWhiteSpace(this.DecimalFieldIndicesCollection[arg]))
                {
                    return;
                }


                string decimalFields = this.DecimalFieldIndicesCollection[arg];
                foreach(string fieldIndex in decimalFields.Split(','))
                {
                    int index = MixERP.Net.Common.Conversion.TryCastInteger(fieldIndex);
                    decimal value = MixERP.Net.Common.Conversion.TryCastDecimal(e.Row.Cells[index].Text);
                    e.Row.Cells[index].Text = string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "{0:N}", value);
                }
            }
        }
        #endregion

        #region "Export Report"
        protected void ExcelImageButton_Click(object sender, ImageClickEventArgs e)
        {
            string html = ReportHidden.Value;
            if(!string.IsNullOrWhiteSpace(html))
            {
                Response.ContentType = "application/force-download";
                Response.AddHeader("content-disposition", "attachment; filename=" + ReportTitleHidden.Value + ".xls");
                Response.Charset = "";
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.ContentType = "application/vnd.ms-excel";
                Response.Write(html);
                Response.Flush();
                Response.Close();
            }
        }

        protected void WordImageButton_Click(object sender, ImageClickEventArgs e)
        {
            string html = ReportHidden.Value;
            if(!string.IsNullOrWhiteSpace(html))
            {
                Response.ContentType = "application/force-download";
                Response.AddHeader("content-disposition", "attachment; filename=" + ReportTitleHidden.Value + ".doc");
                Response.Charset = "";
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.ContentType = "application/vnd.ms-word";
                Response.Write(html);
                Response.Flush();
                Response.Close();
            }
        }
        #endregion

        private void CleanUp()
        {
            for(int i = 0; i < this.DataTableCollection.Count - 1; i++)
            {
                System.Data.DataTable table = this.DataTableCollection[i];
                if(table != null)
                {
                    table.Dispose();
                    if(table != null)
                    {
                        table = null;
                    }
                }

            }
        }

    }

}

