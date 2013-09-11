/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class ReportHelper
    {
        public static DataTable GetDataTable(string sql, Collection<KeyValuePair<string, string>> parameters)
        {
            return MixERP.Net.DatabaseLayer.Helpers.ReportHelper.GetDataTable(sql, parameters);
        }
        
        public static string Parse(string expression)
        {
            if(string.IsNullOrWhiteSpace(expression))
            {
                return string.Empty;
            }
            
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

        public static Collection<Collection<KeyValuePair<string,string>>> BindParameters(string reportPath, Collection<KeyValuePair<string, string>> parameterCollection)
        {
            if(!System.IO.File.Exists(reportPath))
            {
                return null;
            }

            Collection<Collection<KeyValuePair<string, string>>> collection = new Collection<Collection<KeyValuePair<string, string>>>();
            Collection<KeyValuePair<string, string>> parameters = new Collection<KeyValuePair<string, string>>();
            System.Xml.XmlNodeList dataSources = XmlHelper.GetNodes(reportPath, "//DataSource");

            foreach(System.Xml.XmlNode datasource in dataSources)
            {
                foreach(System.Xml.XmlNode parameterNodes in datasource.ChildNodes)
                {
                    if(parameterNodes.Name.Equals("Parameters"))
                    {
                        foreach(System.Xml.XmlNode parameterNode in parameterNodes.ChildNodes)
                        {
                            parameters.Add(new KeyValuePair<string, string>(parameterNode.Attributes["Name"].Value, GetParameterValue(parameterNode.Attributes["Name"].Value, parameterCollection)));
                        }
                    }
                }

                collection.Add(parameters);
            }

            return collection;
        }

        private static string GetParameterValue(string key, Collection<KeyValuePair<string, string>> collection)
        {
            if(string.IsNullOrWhiteSpace(key))
            {
                return string.Empty;
            }

            if(collection == null)
            {
                return string.Empty;
            }

            foreach(KeyValuePair<string, string> item in collection)
            {
                if(item.Key.Equals(key))
                {
                    return item.Value;
                }
            }

            return string.Empty;
        }

        public static Collection<KeyValuePair<string, string>> GetParameters(string reportPath)
        {
            if(!System.IO.File.Exists(reportPath))
            {
                return null;
            }

            Collection<KeyValuePair<string, string>> parameterCollection = new Collection<KeyValuePair<string, string>>();
            System.Xml.XmlNodeList dataSources = XmlHelper.GetNodes(reportPath, "//DataSource");

            foreach(System.Xml.XmlNode datasource in dataSources)
            {
                foreach(System.Xml.XmlNode parameters in datasource.ChildNodes)
                {
                    if(parameters.Name.Equals("Parameters"))
                    {
                        foreach(System.Xml.XmlNode parameter in parameters.ChildNodes)
                        {
                            if(!KeyExists(parameter.Attributes["Name"].Value, parameterCollection))
                            {
                                parameterCollection.Add(new KeyValuePair<string, string>(parameter.Attributes["Name"].Value, parameter.Attributes["Type"].Value));
                            }
                        }
                    }
                }
            }

            return parameterCollection;
        }

        private static bool KeyExists(string key, Collection<KeyValuePair<string, string>> collection)
        {
            foreach(KeyValuePair<string, string> item in collection)
            {
                if(item.Key.Equals(key))
                {
                    return true;
                }
            }

            return false;
        }
    }
}
