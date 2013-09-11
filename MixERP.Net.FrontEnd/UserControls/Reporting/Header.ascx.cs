/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.UserControls.Reporting
{
    public partial class Header : System.Web.UI.UserControl
    {
        private string html;

        public string GetHtml()
        { 
                return html;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string header = System.IO.File.ReadAllText(Server.MapPath("~/Reports/Assets/Header.html"));
            html = MixERP.Net.BusinessLayer.Helpers.ReportHelper.Parse(header);
            HeaderLiteral.Text = html;
        }



    }
}