/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd
{
    public partial class MixErpMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.LoadMenu();
        }

        private void LoadMenu()
        {
            string menu = string.Empty;

            Collection<MixERP.Net.Common.Models.Core.Menu> collection = MixERP.Net.BusinessLayer.Core.Menu.GetMenuCollection(0, 0);
            if(collection.Count > 0)
            {
                foreach(MixERP.Net.Common.Models.Core.Menu model in collection)
                {
                    string menuText = model.MenuText;
                    string url = model.Url;
                    menu += string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<a href='{0}' title='{1}'>{1}</a>", ResolveUrl(url), menuText);
                }
            }

            MenuLiteral.Text = menu;
        }
    }
}