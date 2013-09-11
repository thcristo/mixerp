/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.UserControls
{
    public partial class DateTextBox : System.Web.UI.UserControl
    {
        public new string ID { get; set; }
        public bool Disabled
        {
            get
            {
                return !TextBox1.Enabled;
            }
            set
            {
                TextBox1.Enabled = !value;
            }
        }
        public bool EnableValidation { get; set; }
        public string CssClass {
            get
            {
                return TextBox1.CssClass;
            }
            set
            {
                TextBox1.CssClass = value;
            }
        }
        private string text;
        public string Text
        {
            get
            {
                return TextBox1.Text;
            }
            set
            {
                this.text = value;
            }
        }
        public Unit Width
        {
            get
            {
                return TextBox1.Width;
            }
            set
            {
                TextBox1.Width = value;
            }
        }
        protected void Page_Init(object sender, EventArgs e)
        {
            TextBox1.ID = this.ID;
            
            if(string.IsNullOrEmpty(this.text))
            {
                this.text = DateTime.Now.ToShortDateString();
            }
            
            TextBox1.Text = this.text;
            CalendarExtender1.ID = this.ID + "CalendarExtender";
            CalendarExtender1.Format = CultureInfo.CurrentCulture.DateTimeFormat.ShortDatePattern;
            CalendarExtender1.TodaysDateFormat = CultureInfo.CurrentCulture.DateTimeFormat.LongDatePattern;
            CalendarExtender1.TargetControlID = this.ID;
            CalendarExtender1.PopupButtonID = this.ID;


            if(EnableValidation)
            {
                CompareValidator1.ID = this.ID + "CompareValidator";
                CompareValidator1.ControlToValidate = this.ID;
                CompareValidator1.ValueToCompare = "1/1/1900";
                CompareValidator1.Type = ValidationDataType.Date;
                CompareValidator1.ErrorMessage = Resources.Warnings.InvalidDate;
                CompareValidator1.EnableClientScript = true;
                CompareValidator1.CssClass = "error";
            }
            else
            {
                CompareValidator1.Parent.Controls.Remove(CompareValidator1);
            }
        }
    }
}