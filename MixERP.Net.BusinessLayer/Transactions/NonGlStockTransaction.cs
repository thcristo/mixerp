/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;

namespace MixERP.Net.BusinessLayer.Transactions
{
    public static class NonGLStockTransaction
    {
        public static long Add(string book, DateTime valueDate, string partyCode, int priceTypeId, GridView grid, string referenceNumber, string statementReference)
        {
            MixERP.Net.Common.Models.Transactions.StockMasterModel stockMaster = new MixERP.Net.Common.Models.Transactions.StockMasterModel();
            Collection<MixERP.Net.Common.Models.Transactions.StockMasterDetailModel> details = new Collection<MixERP.Net.Common.Models.Transactions.StockMasterDetailModel>();
            long nonGlStockMasterId = 0;

            stockMaster.PartyCode = partyCode;
            stockMaster.PriceTypeId = priceTypeId;

            if(grid != null)
            {
                if(grid.Rows.Count > 0)
                {
                    foreach(GridViewRow row in grid.Rows)
                    {
                        MixERP.Net.Common.Models.Transactions.StockMasterDetailModel detail = new MixERP.Net.Common.Models.Transactions.StockMasterDetailModel();

                        detail.ItemCode = row.Cells[0].Text;
                        detail.Quantity = MixERP.Net.Common.Conversion.TryCastInteger(row.Cells[2].Text);
                        detail.UnitName = row.Cells[3].Text;
                        detail.Price = MixERP.Net.Common.Conversion.TryCastDecimal(row.Cells[4].Text);
                        detail.Discount = MixERP.Net.Common.Conversion.TryCastDecimal(row.Cells[6].Text);
                        detail.TaxRate = MixERP.Net.Common.Conversion.TryCastDecimal(row.Cells[8].Text);
                        detail.Tax = MixERP.Net.Common.Conversion.TryCastDecimal(row.Cells[9].Text);

                        details.Add(detail);
                    }
                }
            }

            nonGlStockMasterId = MixERP.Net.DatabaseLayer.Transactions.NonGLStockTransaction.Add(book, valueDate, MixERP.Net.BusinessLayer.Helpers.SessionHelper.OfficeId(), MixERP.Net.BusinessLayer.Helpers.SessionHelper.UserId(), MixERP.Net.BusinessLayer.Helpers.SessionHelper.LogOnId(), referenceNumber, statementReference, stockMaster, details);
            return nonGlStockMasterId;
        }

        public static System.Data.DataTable GetView(string book, DateTime dateFrom, DateTime dateTo, string office, string party, string priceType, string user, string referenceNumber, string statementReference)
        {
            return MixERP.Net.DatabaseLayer.Transactions.NonGLStockTransaction.GetView(book, MixERP.Net.BusinessLayer.Helpers.SessionHelper.OfficeId(), dateFrom, dateTo, office, party, priceType, user, referenceNumber, statementReference);
        }
    }
}
