/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.UserControls.Forms
{
    public partial class FormControl : System.Web.UI.UserControl
    {
        private string imageColumn = string.Empty;

        #region Properties
        public bool DenyEdit { get; set; }
        public bool DenyDelete { get; set; }
        public bool DenyAdd { get; set; }
        public string Description { get; set; }
        public string DisplayFields { get; set; }
        public string DisplayViews { get; set; }
        public string Exclude { get; set; }
        public string KeyColumn { get; set; }
        public int PageSize { get; set; }
        public string SelectedValues { get; set; }
        public string Table { get; set; }
        public string TableSchema { get; set; }
        public string Text { get; set; }
        public string View { get; set; }
        public string ViewSchema { get; set; }
        public int Width { get; set; }
        #endregion

        #region Control Events
        protected void Page_Load(object sender, EventArgs e)
        {
            TitleLabel.Text = this.Text;
            this.Page.Title = this.Text;

            if(!string.IsNullOrWhiteSpace(this.Description))
            {
                DescriptionLabel.CssClass = "description";
                DescriptionLabel.Text = this.Description;
            }

            this.LoadGrid();
            using(System.Data.DataTable table = new System.Data.DataTable())
            {
                table.Locale = System.Threading.Thread.CurrentThread.CurrentCulture;
                this.LoadForm(this.FormContainer, table);
            }
        }

        protected void FormGridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                HtmlInputRadioButton radio = new HtmlInputRadioButton();
                radio.ClientIDMode = System.Web.UI.ClientIDMode.Static;
                radio.Name = "SelectRadio";
                radio.ID = "SelectRadio";
                radio.ClientIDMode = System.Web.UI.ClientIDMode.Predictable;
                radio.Value = e.Row.Cells[1].Text;
                radio.Attributes.Add("onclick", "selected(this.id);");
                e.Row.Cells[0].Controls.Add(radio);
            }
            else if(e.Row.RowType == DataControlRowType.Header)
            {
                for(int i = 0; i < e.Row.Cells.Count; i++)
                {
                    string cellText = e.Row.Cells[i].Text;

                    cellText = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", cellText);
                    e.Row.Cells[i].Text = cellText;
                }
            }
        }

        protected void CancelButton_Click(object sender, EventArgs e)
        {
            //Clear the form.
            this.FormContainer.Controls.Clear();

            //Clear grid selection.
            this.ClearSelectedValue();

            //Load the form again.
            using(System.Data.DataTable table = new System.Data.DataTable())
            {
                table.Locale = System.Threading.Thread.CurrentThread.CurrentCulture;
                this.LoadForm(this.FormContainer, table);
            }
        }

        protected void EditButton_Click(object sender, EventArgs e)
        {
            string id = this.GetSelectedValue();
            if(string.IsNullOrWhiteSpace(id))
            {
                return;
            }

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable(this.TableSchema, this.Table, this.KeyColumn, id))
            {
                if(table.Rows.Count.Equals(1))
                {
                    //Clear the form container.
                    FormContainer.Controls.Clear();

                    //Load the form again in the container with values 
                    //retrieved from database.
                    this.LoadForm(this.FormContainer, table);
                    GridPanel.Attributes["style"] = "display:none;";
                    FormPanel.Attributes["style"] = "display:block;";
                }
            }
        }

        protected void DeleteButton_Click(object sender, EventArgs e)
        {
            string id = this.GetSelectedValue();
            if(string.IsNullOrWhiteSpace(id))
            {
                return;
            }

            if(DenyDelete)
            {
                FormLabel.CssClass = "failure";
                FormLabel.Text = Resources.Warnings.AccessDenied;
                return;
            }

            if(MixERP.Net.BusinessLayer.Helpers.FormHelper.DeleteRecord(this.TableSchema, this.Table, this.KeyColumn, id))
            {
                //Refresh the grid.
                this.BindGridView();

                this.DisplaySuccess();
            }

        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            this.Page.Validate();

            if(!this.Page.IsValid)
            {
                return;
            }

            System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> list = this.GetFormCollection(true);
            string id = this.GetSelectedValue();

            if(string.IsNullOrWhiteSpace(id))
            {
                if(DenyAdd)
                {
                    FormLabel.CssClass = "failure";
                    FormLabel.Text = Resources.Warnings.AccessDenied;
                }
                else
                {
                    if(MixERP.Net.BusinessLayer.Helpers.FormHelper.InsertRecord(this.TableSchema, this.Table, list, this.imageColumn))
                    {
                        //Clear the form container.
                        FormContainer.Controls.Clear();

                        //Load the form again.
                        this.LoadForm(this.FormContainer, new System.Data.DataTable());

                        //Refresh the grid.
                        this.BindGridView();

                        this.DisplaySuccess();

                    }
                }
            }
            else
            {
                if(DenyEdit)
                {
                    FormLabel.CssClass = "failure";
                    FormLabel.Text = Resources.Warnings.AccessDenied;
                }
                else
                {
                    if(MixERP.Net.BusinessLayer.Helpers.FormHelper.UpdateRecord(this.TableSchema, this.Table, list, this.KeyColumn, id, this.imageColumn))
                    {
                        //Clear the form container.
                        FormContainer.Controls.Clear();

                        //Load the form again.
                        using(System.Data.DataTable table = new System.Data.DataTable())
                        {
                            table.Locale = System.Threading.Thread.CurrentThread.CurrentCulture;

                            this.LoadForm(this.FormContainer, table);
                        }

                        //Refresh the grid.
                        this.BindGridView();

                        this.DisplaySuccess();
                    }
                    else
                    {
                        FormLabel.CssClass = "failure";
                        FormLabel.Text = Resources.Warnings.UnknownError;
                    }
                }
            }
        }

        #endregion

        private void ClearSelectedValue()
        {
            foreach(GridViewRow row in FormGridView.Rows)
            {
                HtmlInputRadioButton r = (HtmlInputRadioButton)row.Controls[0].Controls[0];
                if(r.Checked)
                {
                    r.Checked = false;
                }
            }
        }

        private string GetSelectedValue()
        {
            foreach(GridViewRow row in FormGridView.Rows)
            {
                HtmlInputRadioButton r = (HtmlInputRadioButton)row.Controls[0].Controls[0];
                if(r.Checked)
                {
                    return r.Value;
                }
            }

            return string.Empty;
        }

        private void LoadGrid()
        {
            bool showAll = (MixERP.Net.Common.Conversion.TryCastString(Request.QueryString["show"]).Equals("all"));

            this.BindGridView();
            this.FormGridView.Width = this.Width;
            this.Pager.RecordCount = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTotalRecords(this.ViewSchema, this.View);
            this.Pager.PageSize = 10;


            if(this.PageSize != 0)
            {
                this.Pager.PageSize = this.PageSize;
            }

            if(showAll)
            {
                this.Pager.PageSize = 1000;
            }


            this.UserIdHidden.Value = MixERP.Net.BusinessLayer.Helpers.SessionHelper.UserName();
            this.OfficeCodeHidden.Value = MixERP.Net.BusinessLayer.Helpers.SessionHelper.OfficeName();
        }

        private void BindGridView()
        {
            bool showAll = (MixERP.Net.Common.Conversion.TryCastString(Request.QueryString["show"]).Equals("all"));

            int limit = 10;
            int offset = 0;

            if(this.PageSize != 0)
            {
                limit = this.PageSize;
            }

            if(showAll)
            {
                limit = 1000;
            }

            if(this.Page.Request["page"] != null)
            {
                offset = (MixERP.Net.Common.Conversion.TryCastInteger(this.Page.Request["page"]) - 1) * limit;
            }


            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetView(this.ViewSchema, this.View, this.KeyColumn, limit, offset))
            {
                this.FormGridView.DataSource = table;
                this.FormGridView.DataBind();
            }
        }


        private void LoadForm(Panel container, System.Data.DataTable values)
        {
            HtmlTable t = new HtmlTable();
            t.Attributes["class"] = "valignmiddle";

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.TableHelper.GetTable(this.TableSchema, this.Table, this.Exclude))
            {
                if(table.Rows.Count > 0)
                {
                    foreach(System.Data.DataRow row in table.Rows)
                    {
                        string columnName = MixERP.Net.Common.Conversion.TryCastString(row["column_name"]);
                        string defaultValue = MixERP.Net.Common.Conversion.TryCastString(row["column_default"]); //nextval('%_seq'::regclass)
                        bool isSerial = defaultValue.StartsWith("nextval", StringComparison.OrdinalIgnoreCase);
                        bool isNullable = MixERP.Net.Common.Conversion.TryCastBoolean(row["is_nullable"]);
                        string dataType = MixERP.Net.Common.Conversion.TryCastString(row["data_type"]);
                        string domain = MixERP.Net.Common.Conversion.TryCastString(row["domain_name"]);
                        int maxLength = MixERP.Net.Common.Conversion.TryCastInteger(row["character_maximum_length"]);

                        string parentTableSchema = MixERP.Net.Common.Conversion.TryCastString(row["references_schema"]);
                        string parentTable = MixERP.Net.Common.Conversion.TryCastString(row["references_table"]);
                        string parentTableColumn = MixERP.Net.Common.Conversion.TryCastString(row["references_field"]);

                        if(values.Rows.Count.Equals(1))
                        {
                            defaultValue = MixERP.Net.Common.Conversion.TryCastString(values.Rows[0][columnName]);
                        }

                        this.AddField(t, columnName, defaultValue, isSerial, isNullable, dataType, domain, maxLength, parentTableSchema, parentTable, parentTableColumn);
                    }
                }
            }

            container.Controls.Add(t);
        }

        private void DisplaySuccess()
        {
            FormLabel.CssClass = "success";
            FormLabel.Text = Resources.Labels.TaskCompletedSuccessfully;

            GridPanel.Attributes["style"] = "display:block;";
            FormPanel.Attributes["style"] = "display:none;";
            MixERP.Net.Common.PageUtility.ExecuteJavaScript("resetForm", "$('#form1').each(function(){this.reset();});", this.Page);
        }

        #region Form Generator
        /// <summary>
        /// This function iterates through all the dynamically added controls, checks their values, and returns a list of column and values mapped as KeyValuePair&lt;column_name, value&gt;.
        /// </summary>
        /// <param name="skipSerial">Skip the PostgreSQL serial column. There is no need to explicity set the value for the serial column. This value should be <strong>true</strong> if you are obtaining the form to insert the record. Set this paramter to <b>false</b> if you want to update the form based on the serial's columns value.</param>
        /// <returns>Returns a list of column and values mapped as KeyValuePair&lt;column_name, value&gt;</returns>
        private System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> GetFormCollection(bool skipSerial)
        {
            System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> list = new System.Collections.ObjectModel.Collection<KeyValuePair<string, string>>();

            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.TableHelper.GetTable(this.TableSchema, this.Table, this.Exclude))
            {
                if(table.Rows.Count > 0)
                {
                    foreach(System.Data.DataRow row in table.Rows)
                    {
                        string columnName = MixERP.Net.Common.Conversion.TryCastString(row["column_name"]);
                        string defaultValue = MixERP.Net.Common.Conversion.TryCastString(row["column_default"]);
                        bool isSerial = defaultValue.StartsWith("nextval", StringComparison.OrdinalIgnoreCase);
                        string parentTableColumn = MixERP.Net.Common.Conversion.TryCastString(row["references_field"]);
                        string dataType = MixERP.Net.Common.Conversion.TryCastString(row["data_type"]);

                        if(skipSerial)
                        {
                            if(isSerial)
                            {
                                continue;
                            }
                        }

                        if(string.IsNullOrWhiteSpace(parentTableColumn))
                        {
                            switch(dataType)
                            {
                                case "national character varying":
                                case "character varying":
                                case "national character":
                                case "character":
                                case "char":
                                case "varchar":
                                case "nvarchar":
                                case "text":
                                case "date":
                                case "smallint":
                                case "integer":
                                case "bigint":
                                case "numeric":
                                case "money":
                                case "double":
                                case "double precision":
                                case "float":
                                case "real":
                                case "currency":
                                    //TextBox
                                    TextBox t = (TextBox)FormContainer.FindControl(columnName + "_textbox");
                                    if(t != null)
                                    {
                                        list.Add(new KeyValuePair<string, string>(columnName, t.Text));
                                    }
                                    break;
                                case "boolean":
                                    RadioButtonList r = (RadioButtonList)FormContainer.FindControl(columnName + "_radiobuttonlist");
                                    list.Add(new KeyValuePair<string, string>(columnName, r.Text));
                                    break;
                                case "bytea":
                                    FileUpload f = (FileUpload)FormContainer.FindControl(columnName + "_fileupload");
                                    string file = this.UploadFile(f);
                                    list.Add(new KeyValuePair<string, string>(columnName, file));
                                    imageColumn = columnName;
                                    break;
                            }

                        }
                        else
                        {
                            //DropDownList
                            DropDownList d = (DropDownList)FormContainer.FindControl(columnName + "_dropdownlist");
                            list.Add(new KeyValuePair<string, string>(columnName, d.Text));
                        }
                    }
                }
            }

            return list;
        }


        private string UploadFile(FileUpload fileUpload)
        {
            string uploadDirectory = Server.MapPath("~/Media/Temp");
            if(!System.IO.Directory.Exists(uploadDirectory))
            {
                System.IO.Directory.CreateDirectory(uploadDirectory);
            }

            string id = Guid.NewGuid().ToString();

            if(fileUpload.HasFile)
            {
                id += System.IO.Path.GetExtension(fileUpload.FileName);
                id = System.IO.Path.Combine(uploadDirectory, id);

                fileUpload.SaveAs(id);
            }

            return id;
        }

        private void AddRow(HtmlTable table, string label, params Control[] controls)
        {
            HtmlTableRow newRow = new HtmlTableRow();
            HtmlTableCell labelCell = new HtmlTableCell();
            HtmlTableCell controlCell = new HtmlTableCell();
            Literal labelLiteral = new Literal();

            labelLiteral.Text = string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<label for='{0}'>{1}</label>", controls[0].ID, label);
            labelCell.Attributes.Add("class", "label-cell");

            labelCell.Controls.Add(labelLiteral);

            foreach(Control control in controls)
            {
                if(control != null)
                {
                    controlCell.Controls.Add(control);
                }
            }

            newRow.Cells.Add(labelCell);
            newRow.Cells.Add(controlCell);
            table.Rows.Add(newRow);
        }

        private void AddField(HtmlTable t, string columnName, string defaultValue, bool isSerial, bool isNullable, string dataType, string domain, int maxLength, string parentTableSchema, string parentTable, string parentTableColumn)
        {
            if(string.IsNullOrWhiteSpace(parentTableColumn))
            {
                switch(dataType)
                {
                    case "national character varying":
                    case "character varying":
                    case "national character":
                    case "character":
                    case "char":
                    case "varchar":
                    case "nvarchar":
                    case "text":
                        this.AddTextBox(t, columnName, defaultValue, isNullable, maxLength);
                        break;
                    case "smallint":
                    case "integer":
                    case "bigint":
                        this.AddNumberTextBox(t, columnName, defaultValue, isSerial, isNullable, maxLength, domain);
                        break;
                    case "numeric":
                    case "money":
                    case "double":
                    case "double precision":
                    case "float":
                    case "real":
                    case "currency":
                        this.AddDecimalTextBox(t, columnName, defaultValue, isNullable, maxLength, domain);
                        break;
                    case "boolean":
                        this.AddRadioButtonList(t, columnName, isNullable, Resources.Titles.YesNo, "true,false", defaultValue);
                        break;
                    case "date":
                        this.AddDateTextBox(t, columnName, defaultValue, isNullable, maxLength);
                        break;
                    case "bytea":
                        this.AddFileUpload(t, columnName, isNullable);
                        break;
                    case "timestamp with time zone":
                        //Do not show this field
                        break;
                }
            }
            else
            {
                this.AddDropDownList(t, columnName, isNullable, parentTableSchema, parentTable, parentTableColumn, defaultValue);
            }
        }
        #endregion

        #region Add Controls
        private void AddDropDownList(HtmlTable t, string columnName, bool isNullable, string tableSchema, string tableName, string tableColumn, string defaultValue)
        {
            string selectedItemValue = string.Empty;
            string dataTextField = string.Empty;
            string relation = string.Empty;
            string viewRelation = string.Empty;
            string selected = string.Empty;
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);
            string schema = string.Empty;
            string view = string.Empty;
            HtmlAnchor itemSelectorAnchor = null;

            DropDownList dropDownList = this.GetDropDownList(columnName + "_dropdownlist");


            using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Helpers.FormHelper.GetTable(tableSchema, tableName))
            {
                if(table.Rows.Count > 0)
                {
                    //See DisplayFields Property for more information.
                    //Loop through all the DisplayFields to match this control.
                    foreach(string displayField in this.DisplayFields.Split(','))
                    {
                        //First, trim the field to remove whitespaces.
                        viewRelation = displayField.Trim();

                        //The fully qualified name of this column.
                        relation = tableSchema + "." + tableName + "." + tableColumn;

                        //Check whether this field matches exactly with this column.
                        if(viewRelation.StartsWith(relation, StringComparison.OrdinalIgnoreCase))
                        {
                            //This field in this loop contained the column name we were looking for.
                            //Now, get the mapped column (display field) to show on the drop down list.
                            //This should be done by :
                            //1. Removing the column name from the field.
                            //2. Removign the the "-->" symbol.
                            //What we get is the name of the field that is displayed on this drop down list.
                            dataTextField = viewRelation.Replace(relation + "-->", "");

                            //Since we have found the field we needed, let's break this loop.
                            break;
                        }
                        //Probably this was not the field we were looking for.
                    }

                    //The display field can be an existing column or a representation of different columns (formula).
                    //Let's check whether the display field really exists.
                    if(!table.Columns.Contains(dataTextField))
                    {
                        //This display field was a formula based various columns.
                        //Now, we are adding a new column "DataTextField" in the data table using the requested formula.
                        table.Columns.Add("DataTextField", typeof(string), dataTextField);
                        dataTextField = "DataTextField";
                    }

                    dropDownList.DataSource = table;
                    dropDownList.DataValueField = tableColumn;
                    dropDownList.DataTextField = dataTextField;
                    dropDownList.DataBind();

                    if(!string.IsNullOrWhiteSpace(this.DisplayViews))
                    {
                        //See DisplayViews Property for more information.
                        //Loop through all the DisplayViews to match this control.
                        foreach(string displayView in this.DisplayViews.Split(','))
                        {
                            //First, trim the field to remove whitespaces.
                            viewRelation = displayView.Trim();

                            //The fully qualified name of this column.
                            relation = tableSchema + "." + tableName + "." + tableColumn;

                            //Check whether this view matches exactly with this column.
                            if(viewRelation.StartsWith(relation, StringComparison.OrdinalIgnoreCase))
                            {
                                //This view in this loop starts with the column name we were looking for.
                                //Now, get the mapped view to show on the modal page.
                                //This should be done by :
                                //1. Removing the column name from the field.
                                //2. Removign the the "-->" symbol.
                                //What we get is the name of the view that is shown on the modal page.
                                viewRelation = viewRelation.Replace(relation + "-->", "");

                                //Since we have found the field we needed, let's break this loop.
                                break;
                            }
                            //Probably this was not the field we were looking for.
                        }

                        schema = viewRelation.Split('.').First();
                        view = viewRelation.Split('.').Last();

                        //Sanitize the schema and the view
                        schema = MixERP.Net.BusinessLayer.DBFactory.Sanitizer.SanitizeIdentifierName(schema);
                        view = MixERP.Net.BusinessLayer.DBFactory.Sanitizer.SanitizeIdentifierName(view);

                        if(string.IsNullOrWhiteSpace(schema) || string.IsNullOrWhiteSpace(view))
                        {
                            schema = string.Empty;
                            view = string.Empty;
                        }
                        else
                        {
                            itemSelectorAnchor = new HtmlAnchor();
                            itemSelectorAnchor.Attributes["class"] = "item-selector";
                            itemSelectorAnchor.HRef = "/General/ItemSelector.aspx?Schema=" + schema + "&View=" + view + "&AssociatedControlId=" + dropDownList.ID;
                        }
                    }

                }
            }


            //Determining the value which will be pre-selected when this drop down list is displayed.

            //If the "defaultValue" parameter has a value, it means that the form is being edited.
            //Check if "defaultValue" is empty.
            if(!string.IsNullOrWhiteSpace(defaultValue))
            {
                selectedItemValue = defaultValue;
            }
            else
            {
                //In this case, this is probably a fresh form for entry.
                //Checking if the "SelectedValues" has a value.
                if(!string.IsNullOrWhiteSpace(this.SelectedValues))
                {
                    foreach(string selectedValue in this.SelectedValues.Split(','))
                    {
                        //Trim whitespaces
                        selected = selectedValue.Trim();

                        //The plain old fully qualified name of this column.
                        relation = tableSchema + "." + tableName + "." + tableColumn;

                        //Checking again whether this field matches exactly with this column.
                        if(selected.StartsWith(relation, StringComparison.OrdinalIgnoreCase))
                        {
                            //This field in this loop contained the column name we were looking for.
                            //Now, get the mapped column (display field) to show on the drop down list.
                            //This should be done by :
                            //1. Removing the column name from the field.
                            //2. Removign the the "-->" symbol.
                            string value = selected.Replace(relation + "-->", "");

                            //Check the type of the value.
                            //If the value starts with single inverted comma, the value is a text.
                            if(value.StartsWith("'", StringComparison.OrdinalIgnoreCase))
                            {
                                //The selected item value from the drop down list text fields.
                                ListItem item = dropDownList.Items.FindByText(value.Replace("'", ""));

                                if(item != null)
                                {
                                    selectedItemValue = item.Value;
                                }
                            }
                            else
                            {
                                selectedItemValue = value;
                            }
                            break;
                        }
                    }
                }
            }


            if(!string.IsNullOrWhiteSpace(selectedItemValue))
            {
                dropDownList.SelectedValue = selectedItemValue;
            }


            if(isNullable)
            {
                dropDownList.Items.Insert(0, new ListItem(String.Empty, String.Empty));
                AddRow(t, label, dropDownList, itemSelectorAnchor);
            }
            else
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(dropDownList);
                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, dropDownList, required, itemSelectorAnchor);
            }

        }

        private void AddRadioButtonList(HtmlTable t, string columnName, bool isNullable, string keys, string values, string selectedValue)
        {
            RadioButtonList radioButtonList = this.GetRadioButtonList(columnName + "_radiobuttonlist", keys, values, selectedValue);
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);

            if(!isNullable)
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(radioButtonList);
                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, radioButtonList, required);
                return;
            }

            AddRow(t, label, radioButtonList);
        }

        private void AddCheckBoxList(HtmlTable t, string columnName, bool isNullable, string keys, string values, string selectedValues)
        {
            CheckBoxList checkBoxList = this.GetCheckBoxList(columnName + "_radiobuttonlist", keys, values, selectedValues);
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);

            if(!isNullable)
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(checkBoxList);
                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, checkBoxList, required);
                return;
            }

            AddRow(t, label, checkBoxList);
        }

        private void AddListItems(ListControl control, string keys, string values, string selectedValues)
        {
            string[] key = keys.Split(',');
            string[] value = values.Split(',');

            if(key.Count() == value.Count())
            {
                for(int i = 0; i < key.Length; i++)
                {
                    ListItem item = new ListItem(key[i].Trim(), value[i].Trim());
                    control.Items.Add(item);
                }
            }

            foreach(ListItem item in control.Items)
            {
                if(control is CheckBoxList)
                {
                    foreach(string selectedValue in selectedValues.Split(','))
                    {
                        if(item.Value.Trim().Equals(selectedValue.Trim()))
                        {
                            item.Selected = true;
                        }
                    }
                }
                else
                {
                    if(item.Value.Trim().Equals(selectedValues.Split(',').Last().Trim()))
                    {
                        item.Selected = true;
                        break;
                    }
                }
            }
        }

        private void AddNumberTextBox(HtmlTable t, string columnName, string defaultValue, bool isSerial, bool isNullable, int maxLength, string domain)
        {
            TextBox textBox = this.GetNumberTextBox(columnName + "_textbox", maxLength);
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);

            if(!defaultValue.StartsWith("nextVal", StringComparison.OrdinalIgnoreCase))
            {
                textBox.Text = defaultValue;
            }

            textBox.Width = 200;

            if(isSerial)
            {
                textBox.ReadOnly = true;
            }
            else
            {
                if(!isNullable)
                {
                    CompareValidator validator = this.GetNumericalValidator(textBox, domain);
                    RequiredFieldValidator required = GetRequiredFieldValidator(textBox);
                    AddRow(t, label + Resources.Setup.RequiredFieldIndicator, textBox, validator, required);
                    return;
                }
            }

            AddRow(t, label, textBox);
        }

        private void AddDecimalTextBox(HtmlTable t, string columnName, string defaultValue, bool isNullable, int maxLength, string domain)
        {
            TextBox textBox = this.GetTextBox(columnName + "_textbox", maxLength);
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);

            CompareValidator validator = this.GetDecimalValidator(textBox, domain);
            textBox.Text = defaultValue;

            if(!isNullable)
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(textBox);
                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, textBox, validator, required);
                return;
            }

            AddRow(t, label, textBox, validator);
        }

        private void AddDateTextBox(HtmlTable t, string columnName, string defaultValue, bool isNullable, int maxLength)
        {
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);

            TextBox textBox = this.GetTextBox(columnName + "_textbox", maxLength);
            textBox.CssClass = "date";

            CompareValidator validator = this.GetDateValidator(textBox);
            AjaxControlToolkit.CalendarExtender extender = new AjaxControlToolkit.CalendarExtender();

            textBox.Width = 70;
            extender.ID = textBox.ID + "_calendar_extender";
            extender.TargetControlID = textBox.ID;
            extender.PopupButtonID = textBox.ID;

            if(!string.IsNullOrWhiteSpace(defaultValue))
            {
                textBox.Text = MixERP.Net.Common.Conversion.TryCastDate(defaultValue).ToShortDateString();
            }


            if(!isNullable)
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(textBox);
                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, textBox, validator, required, extender);
                return;
            }

            AddRow(t, label, textBox, validator, extender);
        }

        private void AddTextBox(HtmlTable t, string columnName, string defaultValue, bool isNullable, int maxLength)
        {
            TextBox textBox = this.GetTextBox(columnName + "_textbox", maxLength);
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);

            textBox.Text = defaultValue;

            if(!isNullable)
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(textBox);
                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, textBox, required);
                return;
            }

            AddRow(t, label, textBox);
        }

        private void AddFileUpload(HtmlTable t, string columnName, bool isNullable)
        {
            string label = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", columnName);
            FileUpload fileUpload = this.GetFileUpload(columnName + "_fileupload");
            RegularExpressionValidator validator = this.GetImageValidator(fileUpload);

            UpdatePanel1.Triggers.Clear();
            ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(SaveButton);

            if(!isNullable)
            {
                RequiredFieldValidator required = GetRequiredFieldValidator(fileUpload);

                AddRow(t, label + Resources.Setup.RequiredFieldIndicator, fileUpload, required, validator);
                return;
            }

            AddRow(t, label, fileUpload, validator);
        }
        #endregion

        #region Get Controls
        private FileUpload GetFileUpload(string id)
        {
            FileUpload fileUpload = new FileUpload();
            fileUpload.ID = id;

            return fileUpload;
        }

        private CheckBoxList GetCheckBoxList(string id, string keys, string values, string selectedValues)
        {
            CheckBoxList list = new CheckBoxList();
            list.ID = id;
            list.ClientIDMode = System.Web.UI.ClientIDMode.Static;

            list.RepeatDirection = RepeatDirection.Horizontal;
            AddListItems(list, keys, values, selectedValues);
            return list;
        }

        private RadioButtonList GetRadioButtonList(string id, string keys, string values, string selectedValues)
        {
            RadioButtonList list = new RadioButtonList();
            list.ID = id;
            list.ClientIDMode = System.Web.UI.ClientIDMode.Static;

            list.RepeatDirection = RepeatDirection.Horizontal;
            AddListItems(list, keys, values, selectedValues);
            return list;
        }

        private DropDownList GetDropDownList(string id, string keys, string values, string selectedValues)
        {
            DropDownList list = new DropDownList();
            list.ID = id;
            list.ClientIDMode = System.Web.UI.ClientIDMode.Static;

            AddListItems(list, keys, values, selectedValues);
            return list;
        }

        private DropDownList GetDropDownList(string id)
        {
            DropDownList dropDownList = new DropDownList();
            dropDownList.ID = id;

            dropDownList.ClientIDMode = System.Web.UI.ClientIDMode.Static;

            return dropDownList;
        }

        private TextBox GetTextBox(string id, int maxLength)
        {
            TextBox textBox = new TextBox();
            textBox.ID = id;

            if(maxLength > 0)
            {
                textBox.MaxLength = maxLength;
            }

            textBox.ClientIDMode = System.Web.UI.ClientIDMode.Static;

            return textBox;
        }

        private TextBox GetNumberTextBox(string id, int maxLength)
        {
            TextBox textBox = this.GetTextBox(id, maxLength);
            textBox.Attributes["type"] = "number";
            return textBox;
        }

        private TextBox GetDateTextBox(string id, int maxLength)
        {
            TextBox textBox = this.GetTextBox(id, maxLength);
            textBox.Attributes["type"] = "date";
            return textBox;
        }
        #endregion

        #region Get Validators
        private CompareValidator GetDateValidator(Control controlToValidate)
        {
            CompareValidator validator = new CompareValidator();
            validator.ID = controlToValidate.ID + "DateValidator";
            validator.ErrorMessage = "<br/>" + Resources.Warnings.InvalidDate;
            validator.CssClass = "form-error";
            validator.ControlToValidate = controlToValidate.ID;
            validator.EnableClientScript = true;
            validator.SetFocusOnError = true;
            validator.Display = ValidatorDisplay.Dynamic;
            validator.Type = ValidationDataType.Date;
            validator.Operator = ValidationCompareOperator.GreaterThan;
            validator.ValueToCompare = "1-1-1900";

            return validator;
        }

        private CompareValidator GetDecimalValidator(Control controlToValidate, string domain)
        {
            CompareValidator validator = new CompareValidator();
            validator.ID = controlToValidate.ID + "DecimalValidator";
            validator.ErrorMessage = "<br/>" + Resources.Warnings.OnlyNumbersAllowed;
            validator.CssClass = "form-error";
            validator.ControlToValidate = controlToValidate.ID;
            validator.EnableClientScript = true;
            validator.SetFocusOnError = true;
            validator.Display = ValidatorDisplay.Dynamic;
            validator.Type = ValidationDataType.Double;

            //MixERP strict data type
            if(domain.Contains("strict"))
            {
                validator.Operator = ValidationCompareOperator.GreaterThan;
            }
            else
            {
                validator.Operator = ValidationCompareOperator.GreaterThanEqual;
            }

            validator.ValueToCompare = "0";

            return validator;
        }

        private CompareValidator GetNumericalValidator(Control controlToValidate, string domain)
        {
            CompareValidator validator = new CompareValidator();
            validator.ID = controlToValidate.ID + "NumberValidator";
            validator.ErrorMessage = "<br/>" + Resources.Warnings.OnlyNumbersAllowed;
            validator.CssClass = "form-error";
            validator.ControlToValidate = controlToValidate.ID;
            validator.EnableClientScript = true;
            validator.SetFocusOnError = true;
            validator.Display = ValidatorDisplay.Dynamic;
            validator.Type = ValidationDataType.Integer;

            //MixERP strict data type
            if(domain.Contains("strict"))
            {
                validator.Operator = ValidationCompareOperator.GreaterThan;
            }
            else
            {
                validator.Operator = ValidationCompareOperator.GreaterThanEqual;
            }

            validator.ValueToCompare = "0";

            return validator;
        }

        private RequiredFieldValidator GetRequiredFieldValidator(Control controlToValidate)
        {
            RequiredFieldValidator validator = new RequiredFieldValidator();
            validator.ID = controlToValidate.ID + "RequiredValidator";
            validator.ErrorMessage = "<br/>" + Resources.Warnings.RequiredField;
            validator.CssClass = "form-error";
            validator.ControlToValidate = controlToValidate.ID;
            validator.EnableClientScript = true;
            validator.SetFocusOnError = true;
            validator.Display = ValidatorDisplay.Dynamic;

            return validator;
        }

        private RegularExpressionValidator GetImageValidator(Control controlToValidate)
        {
            RegularExpressionValidator validator = new RegularExpressionValidator();
            validator.ID = controlToValidate.ID + "RegexValidator";
            validator.ErrorMessage = "<br/>" + Resources.Warnings.InvalidImage;
            validator.CssClass = "form-error";
            validator.ControlToValidate = controlToValidate.ID;
            validator.EnableClientScript = true;
            validator.SetFocusOnError = true;
            validator.Display = ValidatorDisplay.Dynamic;
            validator.ValidationExpression = @"(.*\.([gG][iI][fF]|[jJ][pP][gG]|[jJ][pP][eE][gG]|[bB][mM][pP])$)";
            return validator;
        }
        #endregion

    }
}