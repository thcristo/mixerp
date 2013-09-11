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

namespace MixERP.Net.FrontEnd.Purchase
{
    public partial class DirectPurchase : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Purchase_SaveButtonClick(object sender, EventArgs e)
        {
            DateTime valueDate = MixERP.Net.Common.Conversion.TryCastDate(DirectPurchaseControl.GetForm.DateTextBox.Text);
            int storeId = MixERP.Net.Common.Conversion.TryCastInteger(DirectPurchaseControl.GetForm.StoreDropDownList.SelectedItem.Value);
            bool isCredit = DirectPurchaseControl.GetForm.TransactionTypeRadioButtonList.SelectedItem.Value.Equals(Resources.Titles.Credit); ;
            string partyCode = DirectPurchaseControl.GetForm.PartyDropDownList.SelectedItem.Value;
            GridView grid = DirectPurchaseControl.GetForm.Grid;
            int cashRepositoryId = MixERP.Net.Common.Conversion.TryCastInteger(DirectPurchaseControl.GetForm.CashRepositoryDropDownList.SelectedItem.Value);

            int costCenterId = MixERP.Net.Common.Conversion.TryCastInteger(DirectPurchaseControl.GetForm.CostCenterDropDownList.SelectedItem.Value);
            string referenceNumber = DirectPurchaseControl.GetForm.ReferenceNumberTextBox.Text;
            string statementReference = DirectPurchaseControl.GetForm.StatementReferenceTextBox.Text;

            long transactionMasterId = MixERP.Net.BusinessLayer.Transactions.DirectPurchase.Add(valueDate, storeId, isCredit, partyCode, grid, cashRepositoryId, costCenterId, referenceNumber, statementReference);
            if(transactionMasterId > 0)
            {
                Response.Redirect("~/Purchase/Confirmation/DirectPurchase.aspx?TranId=" + transactionMasterId, true);
            }
        }

    }
}