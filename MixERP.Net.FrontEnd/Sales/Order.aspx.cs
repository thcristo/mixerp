/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.Sales
{
    public partial class Order : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void SalesOrder_SaveButtonClick(object sender, EventArgs e)
        {
            DateTime valueDate = MixERP.Net.Common.Conversion.TryCastDate(SalesOrder.GetForm.DateTextBox.Text);
            string partyCode = SalesOrder.GetForm.PartyDropDownList.SelectedItem.Value;
            int priceTypeId = MixERP.Net.Common.Conversion.TryCastInteger(SalesOrder.GetForm.PriceTypeDropDownList.SelectedItem.Value);
            GridView grid = SalesOrder.GetForm.Grid;
            string referenceNumber = SalesOrder.GetForm.ReferenceNumberTextBox.Text;
            string statementReference = SalesOrder.GetForm.StatementReferenceTextBox.Text;

            long nonGlStockMasterId = MixERP.Net.BusinessLayer.Transactions.NonGLStockTransaction.Add("Sales.Order", valueDate, partyCode, priceTypeId, grid, referenceNumber, statementReference);
            if(nonGlStockMasterId > 0)
            {
                Response.Redirect("~/Dashboard/Index.aspx?TranId=" + nonGlStockMasterId, true);
            }
        }
    }
}