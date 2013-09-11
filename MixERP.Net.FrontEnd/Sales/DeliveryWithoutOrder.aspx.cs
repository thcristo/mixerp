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
    public partial class DeliveryWithoutOrder : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void SalesDeliveryControl_SaveButtonClick(object sender, EventArgs e)
        {
            DateTime valueDate = MixERP.Net.Common.Conversion.TryCastDate(SalesDeliveryControl.GetForm.DateTextBox.Text);
            int storeId = MixERP.Net.Common.Conversion.TryCastInteger(SalesDeliveryControl.GetForm.StoreDropDownList.SelectedItem.Value);
            string partyCode = SalesDeliveryControl.GetForm.PartyDropDownList.SelectedItem.Value;
            int priceTypeId = MixERP.Net.Common.Conversion.TryCastInteger(SalesDeliveryControl.GetForm.PriceTypeDropDownList.SelectedItem.Value);
            GridView grid = SalesDeliveryControl.GetForm.Grid;
            int shipperId = MixERP.Net.Common.Conversion.TryCastInteger(SalesDeliveryControl.GetForm.ShippingCompanyDropDownList.SelectedItem.Value);
            decimal shippingCharge = MixERP.Net.Common.Conversion.TryCastDecimal(SalesDeliveryControl.GetForm.ShippingChargeTextBox.Text);
            int costCenterId = MixERP.Net.Common.Conversion.TryCastInteger(SalesDeliveryControl.GetForm.CostCenterDropDownList.SelectedItem.Value);
            string referenceNumber = SalesDeliveryControl.GetForm.ReferenceNumberTextBox.Text;
            string statementReference = SalesDeliveryControl.GetForm.StatementReferenceTextBox.Text;

            long transactionMasterId = MixERP.Net.BusinessLayer.Transactions.SalesDelivery.Add(valueDate, storeId, partyCode, priceTypeId, grid, shipperId, shippingCharge, costCenterId, referenceNumber, statementReference);
            if(transactionMasterId > 0)
            {
                Response.Redirect("~/Sales/Confirmation/DeliveryWithoutOrder.aspx?TranId=" + transactionMasterId, true);
            }

        }
    }
}