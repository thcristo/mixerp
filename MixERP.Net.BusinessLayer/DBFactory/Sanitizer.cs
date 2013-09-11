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
using System.Text.RegularExpressions;

namespace MixERP.Net.BusinessLayer.DBFactory
{
    public static class Sanitizer
    {
        /// <summary>
        /// Please do not use this function to fix the quotes against SQL injection attack.
        /// This is not a replacement of parameterized statements.
        /// Use this function only when you need to sanitize "column names" and/or "table names"
        /// which cannot be done using standard practices.
        /// </summary>
        /// <param name="identifier">Column name or table name which needs to be sanitized</param>
        /// <returns>
        /// Only alphabets and underscore are allowed characters in identifier name.
        /// Anything else than that will be removed.
        /// </returns>
        public static string SanitizeIdentifierName(string identifier)
        {
            return MixERP.Net.DatabaseLayer.DBFactory.Sanitizer.SanitizeIdentifierName(identifier);
        }

    }
}
