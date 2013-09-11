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

namespace MixERP.Net.Common.Models.Core
{
    public class Menu
    {
        public int MenuId { get; set; }
        public string MenuText { get; set; }
        public string Url { get; set; }
        public string MenuCode { get; set; }
        public int Level { get; set; }
        public int ParentMenuId { get; set; }
    }
}
