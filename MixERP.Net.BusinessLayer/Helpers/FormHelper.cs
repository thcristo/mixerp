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
using System.Web.UI.WebControls;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class FormHelper
    {
        public static DataTable GetView(string tableSchema, string tableName, string orderBy, int limit, int offset)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.GetView(tableSchema, tableName, orderBy, limit, offset);
        }

        public static DataTable GetTable(string tableSchema, string tableName)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.GetTable(tableSchema, tableName);
        }


        public static DataTable GetTable(string tableSchema, string tableName, string columnNames, string columnValues)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.GetTable(tableSchema, tableName, columnNames, columnValues);
        }


        public static DataTable GetTable(string tableSchema, string tableName, string columnNames, string columnValuesLike, int limit)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.GetTable(tableSchema, tableName, columnNames, columnValuesLike, limit);
        }

        public static int GetTotalRecords(string tableSchema, string tableName)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.GetTotalRecords(tableSchema, tableName);
        }

        public static bool InsertRecord(string tableSchema, string tableName, System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> data, string imageColumn)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.InsertRecord(MixERP.Net.BusinessLayer.Helpers.SessionHelper.UserId(), tableSchema, tableName, data, imageColumn);
        }

        public static bool UpdateRecord(string tableSchema, string tableName, System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> data, string keyColumn, string keyColumnValue, string imageColumn)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.UpdateRecord(MixERP.Net.BusinessLayer.Helpers.SessionHelper.UserId(), tableSchema, tableName, data, keyColumn, keyColumnValue, imageColumn);
        }

        public static bool DeleteRecord(string tableSchema, string tableName, string keyColumn, string keyColumnValue)
        {
            return MixERP.Net.DatabaseLayer.Helpers.FormHelper.DeleteRecord(tableSchema, tableName, keyColumn, keyColumnValue);
        }

        public static void MakeDirty(WebControl control)
        {
            if(control != null)
            {
                control.CssClass = "dirty";
                control.Focus();
            }
        }

        public static void RemoveDirty(WebControl control)
        {
            if(control != null)
            {
                control.CssClass = "";
            }
        }


    }
}
