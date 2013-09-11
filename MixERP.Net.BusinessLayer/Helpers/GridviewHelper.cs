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
using System.Web.UI.WebControls;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class GridViewHelper
    {        
        public static void SetFormat(GridView grid, int columnIndex, string format)
        {
            if(grid == null || columnIndex < 0 || string.IsNullOrWhiteSpace(format))
            {
                return;
            }

            BoundField boundField = grid.Columns[columnIndex] as BoundField;

            if(boundField != null)
            {
                boundField.DataFormatString = "{0:" + format + "}";
            }
        }
    }
}
