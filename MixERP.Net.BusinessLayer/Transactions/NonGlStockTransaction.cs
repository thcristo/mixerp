/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
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
            return MixERP.Net.DatabaseLayer.Transactions.NonGLStockTransaction.GetView(MixERP.Net.BusinessLayer.Helpers.SessionHelper.UserId(), book, MixERP.Net.BusinessLayer.Helpers.SessionHelper.OfficeId(), dateFrom, dateTo, office, party, priceType, user, referenceNumber, statementReference);
        }

        public static bool TransactionIdsBelongToSameParty(Collection<int> ids)
        {
            return MixERP.Net.DatabaseLayer.Transactions.NonGLStockTransaction.TransactionIdsBelongToSameParty(ids);
        }

        public static void MergeSalesQuotationToSalesOrder(Collection<int> ids)
        {
            MixERP.Net.Common.Models.Transactions.ProductModel model = new Common.Models.Transactions.ProductModel();
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> products = new Collection<Common.Models.Transactions.ProductDetailsModel>();

            using(DataTable table = MixERP.Net.DatabaseLayer.Transactions.NonGLStockTransaction.GetSalesQuotationView(ids))
            {
                if(table.Rows.Count.Equals(0))
                {
                    return;
                }

                model.ValueDate = MixERP.Net.Common.Conversion.TryCastDate(table.Rows[0]["value_date"]);
                model.PartyId = MixERP.Net.Common.Conversion.TryCastInteger(table.Rows[0]["party_id"]);
                model.PriceTypeId = MixERP.Net.Common.Conversion.TryCastInteger(table.Rows[0]["price_type_id"]);
                model.ReferenceNumber = MixERP.Net.Common.Conversion.TryCastString(table.Rows[0]["reference_number"]);
                model.StatementReference = MixERP.Net.Common.Conversion.TryCastString(table.Rows[0]["statement_reference"]);


                foreach(DataRow row in table.Rows)
                {
                    MixERP.Net.Common.Models.Transactions.ProductDetailsModel product = new Common.Models.Transactions.ProductDetailsModel();

                    product.ItemCode = MixERP.Net.Common.Conversion.TryCastString(row["item_code"]);
                    product.ItemName = MixERP.Net.Common.Conversion.TryCastString(row["item_name"]);
                    product.Unit = MixERP.Net.Common.Conversion.TryCastString(row["unit_name"]);

                    
                    product.Quantity = MixERP.Net.Common.Conversion.TryCastInteger(row["quantity"]);                    
                    product.Price = MixERP.Net.Common.Conversion.TryCastDecimal(row["price"]);
                    product.Amount = product.Quantity * product.Price;
                    
                    product.Discount = MixERP.Net.Common.Conversion.TryCastDecimal(row["discount"]);
                    product.Subtotal = product.Amount - product.Discount;

                    product.Rate = MixERP.Net.Common.Conversion.TryCastDecimal(row["tax_rate"]);
                    product.Tax = MixERP.Net.Common.Conversion.TryCastDecimal(row["tax"]);
                    product.Total = product.Subtotal + product.Tax;

                    products.Add(product);
                }

                model.View = products;
            }

            HttpContext.Current.Session["Product"] = model;
            HttpContext.Current.Response.Redirect("~/Sales/Order.aspx");
        }
    }
}
