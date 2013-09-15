/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
namespace MixERP.Net.Common
{
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Data;
    using System.Drawing;
    using System.Globalization;
    using System.Linq;
    using System.Text;
    using System.Security.Cryptography;
    using System.Text.RegularExpressions;
    using System.Web;

    public static class Conversion
    {

        public static string MapPathReverse(string fullServerPath)
        {
            if(fullServerPath == null)
            {
                return null;
            }

            return @"~\" + fullServerPath.Replace(HttpContext.Current.Request.PhysicalApplicationPath, String.Empty);
        }

        public static short TryCastShort(object value)
        {
            if(value != null)
            {
                short retVal = 0;
                //string numberToParse = RemoveGroupping(value.ToString());
                string numberToParse = value.ToString();

                if(short.TryParse(numberToParse, out retVal))
                {
                    return retVal;
                }
            }

            return 0;
        }

        public static long TryCastLong(object value)
        {
            if(value != null)
            {
                long retVal = 0;
                //string numberToParse = RemoveGroupping(value.ToString());
                string numberToParse = value.ToString();

                if(long.TryParse(numberToParse, out retVal))
                {
                    return retVal;
                }
            }

            return 0;
        }

        public static float TryCastSingle(object value)
        {
            if(value != null)
            {
                float retVal = 0;
                //string numberToParse = RemoveGroupping(value.ToString());
                string numberToParse = value.ToString();

                if(float.TryParse(numberToParse, out retVal))
                {
                    return retVal;
                }
            }

            return 0;
        }

        public static double TryCastDouble(object value)
        {
            if(value != null)
            {
                double retVal = 0;
                //string numberToParse = RemoveGroupping(value.ToString());
                string numberToParse = value.ToString();

                if(double.TryParse(numberToParse, out retVal))
                {
                    return retVal;
                }
            }

            return 0;
        }

        public static int TryCastInteger(object value)
        {
            if(value != null)
            {
                if(value is bool)
                {
                    if(Convert.ToBoolean(value, CultureInfo.InvariantCulture))
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }

                int retVal = 0;
                //string numberToParse = RemoveGroupping(value.ToString());
                string numberToParse = value.ToString();

                if(int.TryParse(numberToParse, out retVal))
                {
                    return retVal;
                }
            }

            return 0;
        }

        public static DateTime TryCastDate(object value)
        {
            try
            {
                if(value == DBNull.Value)
                {
                    return DateTime.MinValue;
                }

                return Convert.ToDateTime(value, System.Threading.Thread.CurrentThread.CurrentCulture);
            }
            catch(FormatException)
            {
                //swallow the exception
            }
            catch(InvalidCastException)
            {
                //swallow the exception
            }

            return DateTime.MinValue;
        }

        //private static string RemoveGroupping(string number)
        //{
        //    string thousandSeparator = Helpers.Parameters.ThousandSeparator();
        //    string decimalSeparator = Helpers.Parameters.DecimalSeparator();

        //    //Remove the thousand separator from the number
        //    number = number.Replace(thousandSeparator, "");

        //    //Replace the decimal separator with "dot".
        //    if(!decimalSeparator.Equals("."))
        //    {
        //        number = number.Replace(decimalSeparator, ".");
        //    }

        //    return number;
        //}

        public static decimal TryCastDecimal(object value)
        {
            if(value != null)
            {
                decimal retVal = 0;
                //string numberToParse = RemoveGroupping(value.ToString());
                string numberToParse = value.ToString();

                if(decimal.TryParse(numberToParse, out retVal))
                {
                    return retVal;
                }
            }

            return 0;
        }

        public static bool TryCastBoolean(object value)
        {
            if(value != null)
            {
                if(value is string)
                {
                    if(value.ToString().ToLower(System.Threading.Thread.CurrentThread.CurrentCulture).Equals("yes"))
                    {
                        return true;
                    }

                    if(value.ToString().ToLower(System.Threading.Thread.CurrentThread.CurrentCulture).Equals("true"))
                    {
                        return true;
                    }
                }

                bool retVal = false;
                if(bool.TryParse(value.ToString(), out retVal))
                {
                    return retVal;
                }
            }

            return false;
        }

        public static bool IsNumeric(string value)
        {
            double number;
            return double.TryParse(value, out number);        
        }

        public static string TryCastString(object value)
        {
            try
            {
                if(value != null)
                {
                    if(value is bool)
                    {
                        if(Convert.ToBoolean(value, CultureInfo.InvariantCulture) == true)
                        {
                            return "true";
                        }
                        else
                        {
                            return "false";
                        }
                    }
                    else
                    {
                        if(value == System.DBNull.Value)
                        {
                            return string.Empty;
                        }
                        else
                        {
                            string retVal = value.ToString();
                            return retVal;
                        }
                    }
                }
                else
                {
                    return string.Empty;
                }
            }
            catch(FormatException)
            {
                //swallow the exception
            }
            catch(InvalidCastException)
            {
                //swallow the exception            
            }

            return string.Empty;
        }

        public static string HashSha512(string password, string salt)
        {
            if(password == null)
            {
                return null;
            }

            if(salt == null)
            {
                return null;
            }

            byte[] bytes = Encoding.Unicode.GetBytes(password + salt);
            using(SHA512CryptoServiceProvider hash = new SHA512CryptoServiceProvider())
            {
                byte[] inArray = hash.ComputeHash(bytes);
                return Convert.ToBase64String(inArray);
            }
        }


        public static Uri GetBackEndUrl(System.Web.HttpContext context, string relativePath)
        {
            string lang = string.Empty;
            string administrationDirectoryName = System.Web.Configuration.WebConfigurationManager.AppSettings["AdministrationDirectoryName"];

            if(context != null)
            {
                if(!string.IsNullOrWhiteSpace(administrationDirectoryName))
                {
                    if((context.Session == null) || (context.Session["lang"] == null || string.IsNullOrWhiteSpace(context.Session["lang"] as string)))
                    {
                        lang = "en-US";
                    }
                    else
                    {
                        lang = context.Session["lang"] as string;
                    }

                    System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo(lang);
                    if(culture.TwoLetterISOLanguageName == "iv")
                    {
                        culture = new System.Globalization.CultureInfo("en-US");
                    }

                    string virtualDirectory = context.Request.ApplicationPath;
                    bool isSecure = context.Request.IsSecureConnection;
                    string domain = context.Request.Url.DnsSafeHost;
                    int port = context.Request.Url.Port;
                    string path = string.Empty;

                    if(virtualDirectory == "/")
                    {
                        path = string.Format(CultureInfo.InvariantCulture, "{0}:{1}/{2}/{3}/{4}/", domain, port.ToString(CultureInfo.InvariantCulture), administrationDirectoryName, culture.TwoLetterISOLanguageName, relativePath);
                    }
                    else
                    {
                        path = string.Format(CultureInfo.InvariantCulture, "{0}:{1}{2}/{3}/{4}/{5}/", domain, port.ToString(CultureInfo.InvariantCulture), virtualDirectory, administrationDirectoryName, culture.TwoLetterISOLanguageName, relativePath);
                    }

                    if(isSecure)
                    {
                        path = "https://" + path;
                    }
                    else
                    {
                        path = "http://" + path;
                    }

                    return new Uri(path, UriKind.Absolute);
                }
            }
            return new Uri("", UriKind.Relative);
        }

        public static DateTime GetLocalDateTime(string timeZone, DateTime utc)
        {
            TimeZoneInfo zone = TimeZoneInfo.FindSystemTimeZoneById(timeZone);
            return TimeZoneInfo.ConvertTimeFromUtc(utc, zone);
        }

        public static string GetLocalDateTimeString(string timeZone, DateTime utc)
        {
            TimeZoneInfo zone = TimeZoneInfo.FindSystemTimeZoneById(timeZone);
            DateTime time = TimeZoneInfo.ConvertTimeFromUtc(utc, zone);
            return time.ToLongDateString() + " " + time.ToLongTimeString() + " " + zone.DisplayName;
        }

        public static byte[] TryCastByteArray(Bitmap bitmap)
        {
            ImageConverter converter = new ImageConverter();
            return (byte[])converter.ConvertTo(bitmap, typeof(byte[]));
        }

        public static byte[] TryCastByteArray(Image image)
        {
            ImageConverter converter = new ImageConverter();
            return (byte[])converter.ConvertTo(image, typeof(byte[]));
        }

        public static System.Data.DataTable ConvertListToDataTable<T>(System.Collections.Generic.IList<T> list)
        {
            if(list == null)
            {
                return null;
            }

            System.ComponentModel.PropertyDescriptorCollection props = System.ComponentModel.TypeDescriptor.GetProperties(typeof(T));

            using(System.Data.DataTable table = new System.Data.DataTable())
            {
                table.Locale = System.Threading.Thread.CurrentThread.CurrentCulture;

                for(int i = 0; i < props.Count; i++)
                {
                    System.ComponentModel.PropertyDescriptor prop = props[i];
                    table.Columns.Add(prop.Name, prop.PropertyType);
                }
                object[] values = new object[props.Count];
                foreach(T item in list)
                {
                    for(int i = 0; i < values.Length; i++)
                    {
                        values[i] = props[i].GetValue(item);
                    }
                    table.Rows.Add(values);
                }
                return table;
            }
        }

        public static byte[] ConvertImageToByteArray(System.Drawing.Image imageToConvert, System.Drawing.Imaging.ImageFormat formatOfImage)
        {
            if(imageToConvert == null)
            {
                return null;
            }

            using(System.IO.MemoryStream ms = new System.IO.MemoryStream())
            {
                imageToConvert.Save(ms, formatOfImage);
                return ms.ToArray();
            }
        }
    }
}
