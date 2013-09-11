/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd
{
    public partial class RuntimeError : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string server = Request.ServerVariables["SERVER_SOFTWARE"];

            //This is visual studio
            if(string.IsNullOrWhiteSpace(server))
            {
                this.DisplayError();
            }
            else
            {
                bool displayError = System.Configuration.ConfigurationManager.AppSettings["DisplayError"].Equals("true");
                if(displayError)
                {
                    this.DisplayError();
                }
            }

        }

        private void DisplayError()
        {
            Exception ex = (Exception)this.Page.Session["ex"];
            StringBuilder s = new StringBuilder();

            if(ex != null)
            {
                s.Append(string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<hr class='hr' />"));
                s.Append(string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<h2>{0}</h2>", ex.Message));

                ExceptionLiteral.Text = s.ToString();
            }
        }

    }
}