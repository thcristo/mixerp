/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace MixERP.Net.BusinessLayer.Office
{
    public static class CashRepositories
    {
        public static DataTable GetCashRepositories()
        {
            return MixERP.Net.DatabaseLayer.Office.CashRepositories.GetCashRepositories();
        }

        public static DataTable GetCashRepositories(int officeId)
        {
            //TODO: Bind this instance to a collection of entities.
            return MixERP.Net.DatabaseLayer.Office.CashRepositories.GetCashRepositories(officeId);
        }

        public static decimal GetBalance(int cashRepositoryId)
        {
            return MixERP.Net.DatabaseLayer.Office.CashRepositories.GetBalance(cashRepositoryId);
        }

        public static string GetDisplayField()
        {
            string displayField = MixERP.Net.Common.Helpers.ConfigurationHelper.GetSectionKey("MixERPDbParameters", "CashRepositoryDisplayField");
            if(string.IsNullOrWhiteSpace(displayField))
            {
                displayField = "cash_repository_name";
            }

            return displayField;
        }
    }
}
