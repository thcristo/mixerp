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
using System.Xml;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class XmlHelper
    {
        public static XmlNodeList GetNodes(string path, string name)
        {
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(path);
            return doc.SelectNodes(name);
        }

        public static string GetNodeText(string path, string name)
        {
            System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
            doc.Load(path);
            return doc.SelectSingleNode(name).InnerXml;
        }

    }
}
