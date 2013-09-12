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
using System.Text.RegularExpressions;
using System.Web;

namespace MixERP.Net.BusinessLayer.Reporting
{
    public class ReportParser
    {
        public static string ParseExpression(string expression)
        {
            if(string.IsNullOrWhiteSpace(expression))
            {
                return string.Empty;
            }

            //Todo:Parameterize LogoPath in web.config
            expression = expression.Replace("{LogoPath}", MixERP.Net.Common.PageUtility.GetCurrentDomainName() + MixERP.Net.Common.PageUtility.ResolveUrl("~/Themes/purple/mixerp-logo-light.png"));
            expression = expression.Replace("{PrintDate}", System.DateTime.Now.ToString());

            foreach(var match in Regex.Matches(expression, "{.*?}"))
            {
                string word = match.ToString();


                if(word.StartsWith("{Session.", StringComparison.OrdinalIgnoreCase))
                {
                    string sessionKey = RemoveBraces(word);
                    sessionKey = sessionKey.Replace("Session.", "");
                    sessionKey = sessionKey.Trim();
                    expression = expression.Replace(word, GetSessionValue(sessionKey));
                }
                else if(word.StartsWith("{Resources.", StringComparison.OrdinalIgnoreCase))
                {
                    string res = RemoveBraces(word);
                    string[] resource = res.Split('.');

                    expression = expression.Replace(word, MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString(resource[1], resource[2]));
                }
            }

            return expression;
        }

        public static string ParseDataSource(string expression, System.Collections.ObjectModel.Collection<System.Data.DataTable> table)
        {
            foreach(var match in Regex.Matches(expression, "{.*?}"))
            {
                string word = match.ToString();

                if(word.StartsWith("{DataSource", StringComparison.OrdinalIgnoreCase))
                {

                    int index = MixERP.Net.Common.Conversion.TryCastInteger(word.Split('.').First().Replace("{DataSource[", "").Replace("]", ""));
                    string column = word.Split('.').Last().Replace("}", "");

                    if(table[index] != null)
                    {
                        if(table[index].Rows.Count > 0)
                        {
                            if(table[index].Columns.Contains(column))
                            {
                                string value = table[index].Rows[0][column].ToString();
                                expression = expression.Replace(word, value);
                            }
                        }
                    }
                }
            }

            return expression;
        }

        public static string RemoveBraces(string expression)
        {
            if(string.IsNullOrWhiteSpace(expression))
            {
                return string.Empty;
            }

            return expression.Replace("{", "").Replace("}", "");
        }

        public static string GetSessionValue(string key)
        {
            var val = HttpContext.Current.Session[key];

            if(val != null)
            {
                return val.ToString();
            }

            return string.Empty;
        }

    }
}
