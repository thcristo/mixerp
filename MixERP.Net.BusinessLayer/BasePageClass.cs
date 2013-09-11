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
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.BusinessLayer
{
    public class BasePageClass : System.Web.UI.Page
    {
        /// <summary>
        /// Use this parameter on the Page_Init event of member pages.
        /// This parameter ensures that the user is not redirected to the login page 
        /// even when the user is not logged in.
        /// </summary>
        public bool NoLogOn { get; set; }
        
        /// <summary>
        /// Since we save the menu on the database, this parameter is only used 
        /// when there is no associated record of this page's url or path in the menu table.
        /// Use this to override or fake the page's url or path. This forces navigation menus 
        /// on the left hand side to be displayed in regards with the specified path.
        /// </summary>
        public string OverridePath { get; set; }
        
        protected override void OnLoad(EventArgs e)
        {
            if(string.IsNullOrWhiteSpace(OverridePath))
            {
                OverridePath = this.Page.Request.Url.AbsolutePath;
            }
            
            Literal menuLiteral = ((Literal)MixERP.Net.Common.PageUtility.FindControlIterative(this.Master, "ContentMenuLiteral"));

            if(menuLiteral != null)
            {
                string menu = MixERP.Net.BusinessLayer.Helpers.MenuHelper.GetContentPageMenu(this.Page, this.OverridePath);
                menuLiteral.Text = menu;            
            }

            base.OnLoad(e);
        }

        protected override void OnPreInit(EventArgs e)
        {
            base.OnPreInit(e);
        }

        protected override void InitializeCulture()
        {
            SetCulture();
            base.InitializeCulture();
        }


        protected override void OnInit(EventArgs e)
        {
            if(!IsPostBack)
            {
                if(Request.IsAuthenticated)
                {
                    if(Context.Session == null)
                    {
                        SetSession();
                    }
                    else
                    {
                        if(Context.Session["UserId"] == null)
                        {
                            SetSession();
                        }
                    }
                }
                else
                {
                    if(!this.NoLogOn)
                    {
                        RequestLogOnPage();
                    }
                }
            }

            base.OnInit(e);
        }

        private static void SetCulture()
        {
            //Todo
            Thread.CurrentThread.CurrentCulture = new CultureInfo(CultureInfo.InvariantCulture.Name);
            LoadCulture(Thread.CurrentThread.CurrentCulture);

            Thread.CurrentThread.CurrentUICulture = new CultureInfo(CultureInfo.InvariantCulture.Name);
            LoadCulture(Thread.CurrentThread.CurrentUICulture);
        }

        private static void LoadCulture(CultureInfo c)
        {
            NumberFormatInfo numberFormat = c.NumberFormat;
            numberFormat.NumberGroupSeparator = MixERP.Net.Common.Helpers.Parameters.ThousandSeparator();
            numberFormat.NumberDecimalSeparator = MixERP.Net.Common.Helpers.Parameters.DecimalSeparator();
            numberFormat.NumberDecimalDigits = MixERP.Net.Common.Conversion.TryCastInteger(MixERP.Net.Common.Helpers.Parameters.DecimalPlaces());
            numberFormat.CurrencySymbol = MixERP.Net.Common.Helpers.Parameters.CurrencySymbol();
            numberFormat.CurrencyGroupSeparator = MixERP.Net.Common.Helpers.Parameters.ThousandSeparator();
            numberFormat.CurrencyDecimalSeparator = MixERP.Net.Common.Helpers.Parameters.DecimalSeparator();
            numberFormat.CurrencyDecimalDigits = MixERP.Net.Common.Conversion.TryCastInteger(MixERP.Net.Common.Helpers.Parameters.DecimalPlaces());

            DateTimeFormatInfo dateFormat = c.DateTimeFormat;
            dateFormat.ShortDatePattern = MixERP.Net.Common.Helpers.Parameters.ShortDateFormat();
            dateFormat.LongDatePattern = MixERP.Net.Common.Helpers.Parameters.LongDateFormat();
            dateFormat.ShortTimePattern = MixERP.Net.Common.Helpers.Parameters.ShortTimeFormat();
            dateFormat.LongTimePattern = MixERP.Net.Common.Helpers.Parameters.LongTimeFormat();                    
        }

        private void SetSession()
        {
            MixERP.Net.BusinessLayer.Security.User.SetSession(this.Page, User.Identity.Name);
        }

        public static void RequestLogOnPage()
        {
            FormsAuthentication.SignOut();
            string currentUrl = HttpContext.Current.Request.RawUrl;
            string loginPageUrl = FormsAuthentication.LoginUrl;
            HttpContext.Current.Response.Redirect(String.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "{0}?ReturnUrl={1}", loginPageUrl, currentUrl));
        }
    }
}
