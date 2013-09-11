/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Text;
using System.Data;
using System.Collections.ObjectModel;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class MenuHelper
    {
        public static string GetContentPageMenu(System.Web.UI.Control page, string path)
        {
            if(page != null)
            {
                string menu = string.Empty;
                Collection<MixERP.Net.Common.Models.Core.Menu> rootMenus = MixERP.Net.BusinessLayer.Core.Menu.GetRootMenuCollection(path);

                if(rootMenus.Count > 0)
                {
                    foreach(MixERP.Net.Common.Models.Core.Menu rootMenu in rootMenus)
                    {

                        menu += string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<div class='sub-menu'><div class='menu-title'>{0}</div>", rootMenu.MenuText);

                        Collection<MixERP.Net.Common.Models.Core.Menu> childMenus = MixERP.Net.BusinessLayer.Core.Menu.GetMenuCollection(rootMenu.MenuId, 2);

                        if(childMenus.Count > 0)
                        {
                            foreach(MixERP.Net.Common.Models.Core.Menu childMenu in childMenus)
                            {
                                menu += string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<a href='{0}' title='{1}' class='sub-menu-anchor'>{1}</a>", page.ResolveUrl(childMenu.Url), childMenu.MenuText);
                            }
                        }

                        menu += "</div>";
                    }
                }

                return menu;
            }

            return null;
        }

        public static string GetPageMenu(System.Web.UI.Page page)
        {
            if(page != null)
            {
                string menu = string.Empty;

                Collection<MixERP.Net.Common.Models.Core.Menu> menuCollection = MixERP.Net.BusinessLayer.Core.Menu.GetMenuCollection(page.Request.Url.AbsolutePath, 1);

                if(menuCollection.Count > 0)
                {
                    foreach(MixERP.Net.Common.Models.Core.Menu model in menuCollection)
                    {
                        menu += string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<div class='menu-panel'><div class='menu-header'>{0}</div><ul>", model.MenuText);

                        Collection<MixERP.Net.Common.Models.Core.Menu> childMenus = MixERP.Net.BusinessLayer.Core.Menu.GetMenuCollection(model.MenuId, 2);

                        if(childMenus.Count > 0)
                        {
                            foreach(MixERP.Net.Common.Models.Core.Menu childMenu in childMenus)
                            {
                                menu += string.Format(System.Threading.Thread.CurrentThread.CurrentCulture, "<li><a href='{0}' title='{1}'>{1}</a></li>", page.ResolveUrl(childMenu.Url), childMenu.MenuText);
                            }
                        }

                        menu += "</ul></div>";
                    }
                }

                menu += "<div style='clear:both;'></div>";
                return menu;
            }

            return null;
        }
    }
}
