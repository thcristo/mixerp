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
using System.Data;
using System.Data.Common;
using System.Collections.ObjectModel;

namespace MixERP.Net.BusinessLayer.Core
{
    public static class Menu
    {
        public static Collection<MixERP.Net.Common.Models.Core.Menu> GetMenuCollection(string path, short level)
        {
            Collection<MixERP.Net.Common.Models.Core.Menu> collection = new Collection<Common.Models.Core.Menu>();

            foreach(DataRow row in MixERP.Net.DatabaseLayer.Core.Menu.GetMenuTable(path, level).Rows)
            {
                MixERP.Net.Common.Models.Core.Menu model = new Common.Models.Core.Menu();

                model.MenuId = MixERP.Net.Common.Conversion.TryCastInteger(row["menu_id"]);
                model.MenuText = MixERP.Net.Common.Conversion.TryCastString(row["menu_text"]);
                model.Url = MixERP.Net.Common.Conversion.TryCastString(row["url"]);
                model.MenuCode = MixERP.Net.Common.Conversion.TryCastString(row["menu_code"]);
                model.Level = MixERP.Net.Common.Conversion.TryCastInteger(row["level"]);
                model.ParentMenuId = MixERP.Net.Common.Conversion.TryCastInteger(row["parent_menu_id"]);

                collection.Add(model);
            }

            return collection;
        }

        public static Collection<MixERP.Net.Common.Models.Core.Menu> GetRootMenuCollection(string path)
        {
            Collection<MixERP.Net.Common.Models.Core.Menu> collection = new Collection<Common.Models.Core.Menu>();

            foreach(DataRow row in MixERP.Net.DatabaseLayer.Core.Menu.GetRootMenuTable(path).Rows)
            {
                MixERP.Net.Common.Models.Core.Menu model = new Common.Models.Core.Menu();

                model.MenuId = MixERP.Net.Common.Conversion.TryCastInteger(row["menu_id"]);
                model.MenuText = MixERP.Net.Common.Conversion.TryCastString(row["menu_text"]);
                model.Url = MixERP.Net.Common.Conversion.TryCastString(row["url"]);
                model.MenuCode = MixERP.Net.Common.Conversion.TryCastString(row["menu_code"]);
                model.Level = MixERP.Net.Common.Conversion.TryCastInteger(row["level"]);
                model.ParentMenuId = MixERP.Net.Common.Conversion.TryCastInteger(row["parent_menu_id"]);

                collection.Add(model);
            }

            return collection;
        }

        public static Collection<MixERP.Net.Common.Models.Core.Menu> GetMenuCollection(int parentMenuId, short level)
        {
            Collection<MixERP.Net.Common.Models.Core.Menu> collection = new Collection<Common.Models.Core.Menu>();

            foreach(DataRow row in MixERP.Net.DatabaseLayer.Core.Menu.GetMenuTable(parentMenuId, level).Rows)
            {
                MixERP.Net.Common.Models.Core.Menu model = new Common.Models.Core.Menu();

                model.MenuId = MixERP.Net.Common.Conversion.TryCastInteger(row["menu_id"]);
                model.MenuText = MixERP.Net.Common.Conversion.TryCastString(row["menu_text"]);
                model.Url = MixERP.Net.Common.Conversion.TryCastString(row["url"]);
                model.MenuCode = MixERP.Net.Common.Conversion.TryCastString(row["menu_code"]);
                model.Level = MixERP.Net.Common.Conversion.TryCastInteger(row["level"]);
                model.ParentMenuId = MixERP.Net.Common.Conversion.TryCastInteger(row["parent_menu_id"]);

                collection.Add(model);
            }

            return collection;
        }
    }
}
