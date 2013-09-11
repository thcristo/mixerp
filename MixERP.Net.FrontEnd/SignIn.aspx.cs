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

namespace MixERP.Net.FrontEnd
{
    public partial class SignIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            UserIdTextBox.Focus();

            if(!IsPostBack)
            {
                if(User.Identity.IsAuthenticated)
                {
                    string user = User.Identity.Name;
                    if(!string.IsNullOrWhiteSpace(user))
                    {
                        string sessionUser = MixERP.Net.Common.Conversion.TryCastString(this.Page.Session["UserName"]);

                        if(string.IsNullOrWhiteSpace(sessionUser))
                        {
                            MixERP.Net.BusinessLayer.Security.User.SetSession(this.Page, user);
                        }

                        Response.Redirect("~/Dashboard/Index.aspx", true);

                    }
                }
            }
        }

        protected void SignInButton_Click(object sender, EventArgs e)
        {
            int officeId = MixERP.Net.Common.Conversion.TryCastInteger(BranchDropDownList.SelectedItem.Value);
            bool results = MixERP.Net.BusinessLayer.Security.User.SignIn(officeId, UserIdTextBox.Text, PasswordTextBox.Text, RememberMe.Checked, this.Page);

            if(!results)
            {
                MessageLiteral.Text = "<span class='error-message'>" + Resources.Warnings.UserIdOrPasswordIncorrect + "</span>";
            }
        }
    }
}