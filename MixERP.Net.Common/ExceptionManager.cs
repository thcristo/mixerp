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

namespace MixERP.Net.Common
{
    public static class ExceptionManager
    {
        public static void HandleException(Exception ex)
        {
            if(ex == null)
            {
                return;
            }
            
            var exception = ex;

            if(ex.GetBaseException() != null)
            {
                exception = ex.GetBaseException();
            }
            
            System.Web.HttpContext.Current.Session["ex"] = exception;
            System.Web.HttpContext.Current.Response.Redirect("~/RuntimeError.aspx", true);
        }
    }
}
