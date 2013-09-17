/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.VisualBasic;

namespace MixERP.Net.FrontEnd.UserControls.Products
{
    public partial class ProductControl : System.Web.UI.UserControl
    {
        public enum TranType { Sales, Purchase }
        public TranType TransactionType { get; set; }
        public enum SubTranType { Direct, Quotation, Order, /*Readonly*/ Delivery,/*Readonly*/ Receipt, /*Readonly*/ Invoice }
        public SubTranType SubType { get; set; }
        public string Text { get; set; }
        public GridView Grid { get { return ProductGridView; } }
        public bool DisplayTransactionTypeRadioButtonList { get; set; }
        public bool VerifyStock { get; set; }
        public bool ShowCashRepository { get; set; }

        public ControlCollection GetForm
        {
            get
            {
                return this.GetControls();
            }
        }

        public class ControlCollection
        {
            public MixERP.Net.FrontEnd.UserControls.DateTextBox DateTextBox { get; set; }
            public DropDownList StoreDropDownList { get; set; }
            public RadioButtonList TransactionTypeRadioButtonList { get; set; }
            public TextBox PartyCodeTextBox { get; set; }
            public DropDownList PartyDropDownList { get; set; }
            public DropDownList PriceTypeDropDownList { get; set; }
            public TextBox ReferenceNumberTextBox { get; set; }
            public GridView Grid { get; set; }
            public TextBox RunningTotalTextBox { get; set; }
            public TextBox TaxTotalTextBox { get; set; }
            public TextBox GrandTotalTextBox { get; set; }
            public DropDownList ShippingAddressDropDownList { get; set; }
            public DropDownList ShippingCompanyDropDownList { get; set; }
            public TextBox ShippingChargeTextBox { get; set; }
            public DropDownList CashRepositoryDropDownList { get; set; }
            public TextBox CashRepositoryBalanceTextBox { get; set; }
            public DropDownList CostCenterDropDownList { get; set; }
            public DropDownList AgentDropDownList { get; set; }
            public TextBox StatementReferenceTextBox { get; set; }
        }

        private ControlCollection GetControls()
        {
            ControlCollection collection = new ControlCollection();
            collection.DateTextBox = this.DateTextBox;
            collection.StoreDropDownList = this.StoreDropDownList;
            collection.TransactionTypeRadioButtonList = this.TransactionTypeRadioButtonList;
            collection.PartyCodeTextBox = this.PartyCodeTextBox;
            collection.PartyDropDownList = this.PartyDropDownList;
            collection.PriceTypeDropDownList = this.PriceTypeDropDownList;
            collection.ReferenceNumberTextBox = this.ReferenceNumberTextBox;
            collection.Grid = this.ProductGridView;
            collection.RunningTotalTextBox = this.RunningTotalTextBox;
            collection.TaxTotalTextBox = this.TaxTotalTextBox;
            collection.GrandTotalTextBox = this.GrandTotalTextBox;
            collection.ShippingAddressDropDownList = this.ShippingAddressDropDownList;
            collection.ShippingCompanyDropDownList = this.ShippingCompanyDropDownList;
            collection.ShippingChargeTextBox = this.ShippingChargeTextBox;
            collection.CashRepositoryDropDownList = this.CashRepositoryDropDownList;
            collection.CashRepositoryBalanceTextBox = this.CashRepositoryBalanceTextBox;
            collection.CostCenterDropDownList = this.CostCenterDropDownList;
            collection.AgentDropDownList = this.SalesPersonDropDownList;
            collection.StatementReferenceTextBox = this.StatementReferenceTextBox;
            return collection;
        }


        public Unit TopPanelWidth
        {
            get
            {
                return this.TopPanel.Width;
            }
            set
            {
                this.TopPanel.Width = value;
            }

        }

        public event EventHandler SaveButtonClick;

        public virtual void OnSaveButtonClick(object sender, EventArgs e)
        {
            if(SaveButtonClick != null)
            {
                this.SaveButtonClick(sender, e);
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            //Validation Check Start
            if(ProductGridView.Rows.Count.Equals(0))
            {
                ErrorLabel.Text = Resources.Warnings.NoItemFound;
                return;
            }

            if(this.TransactionType == TranType.Purchase && CashRepositoryRow.Visible)
            {
                this.UpdateRepositoryBalance();

                decimal repositoryBalance = MixERP.Net.Common.Conversion.TryCastDecimal(CashRepositoryBalanceTextBox.Text);
                decimal grandTotal = MixERP.Net.Common.Conversion.TryCastDecimal(GrandTotalTextBox.Text);

                if(grandTotal > repositoryBalance)
                {
                    ErrorLabel.Text = Resources.Warnings.NotEnoughCash;
                    return;
                }
            }

            if(!string.IsNullOrWhiteSpace(ShippingChargeTextBox.Text))
            {
                if(!MixERP.Net.Common.Conversion.IsNumeric(ShippingChargeTextBox.Text))
                {
                    MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(ShippingChargeTextBox);
                    return;
                }
            }


            //Validation Check End

            //Now exposing the button click event.
            this.OnSaveButtonClick(sender, e);
        }

        protected void ProductGridView_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table = this.GetTable();
            GridViewRow row = (GridViewRow)(((ImageButton)e.CommandSource).NamingContainer);
            int index = row.RowIndex;

            table.RemoveAt(index);
            Session[this.ID] = table;
            this.BindGridView();
            //UpdatePanel1.Update();
        }

        protected void ProductGridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                ImageButton lb = e.Row.FindControl("DeleteImageButton") as ImageButton;
                ScriptManager.GetCurrent(this.Page).RegisterAsyncPostBackControl(lb);
            }
        }

        #region "Page Initialization"
        protected void Page_Init(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                this.ClearSession(this.ID);
            }
            
            this.LoadValuesFromSession();
            this.InitializeControls();
            this.BindGridView();
            ScriptManager1.RegisterAsyncPostBackControl(ProductGridView);
        }

        private void LoadValuesFromSession()
        {
            if(Session["Product"] == null)
            {
                return;
            }

            MixERP.Net.Common.Models.Transactions.ProductModel model = Session["Product"] as MixERP.Net.Common.Models.Transactions.ProductModel;

            if(model == null)
            {
                return;
            }

            if(PartyDropDownList.SelectedItem != null)
            {
                PartyDropDownList.SelectedItem.Value = model.PartyId.ToString();
            }

            if(PriceTypeDropDownList.SelectedItem != null)
            {
                PriceTypeDropDownList.SelectedItem.Value = model.PriceTypeId.ToString();
            }

            ReferenceNumberTextBox.Text = model.ReferenceNumber;
            StatementReferenceTextBox.Text = model.StatementReference;

            Session[this.ID] = model.View;
            this.ClearSession("Product");
        }

        private void ClearSession(string key)
        {
            if(Session[key] != null)
            {
                Session.Remove(key);
            }
        }

        private void LoadCostCenters()
        {
            if(this.SubType == SubTranType.Direct || this.SubType == SubTranType.Invoice || this.SubType == SubTranType.Delivery || this.SubType == SubTranType.Receipt)
            {
                MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(CostCenterDropDownList, "office", "cost_centers", "cost_center_id", MixERP.Net.BusinessLayer.Office.CostCenters.GetDisplayField());
            }
            else
            {
                CostCenterRow.Visible = false;
            }
        }

        private void LoadStores()
        {
            if(this.SubType == SubTranType.Direct || this.SubType == SubTranType.Invoice || this.SubType == SubTranType.Delivery || this.SubType == SubTranType.Receipt)
            {
                MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(StoreDropDownList, "office", "stores", "store_id", MixERP.Net.BusinessLayer.Office.Stores.GetDisplayField());
            }
            else
            {
                StoreLiteral.Visible = false;
                StoreDropDownList.Visible = false;
            }
        }

        private void LoadCashRepositories()
        {
            if(this.ShowCashRepository)
            {
                using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Office.CashRepositories.GetCashRepositories(MixERP.Net.BusinessLayer.Helpers.SessionHelper.OfficeId()))
                {
                    MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(CashRepositoryDropDownList, table, "cash_repository_id", MixERP.Net.BusinessLayer.Office.CashRepositories.GetDisplayField());
                    this.UpdateRepositoryBalance();
                }
            }
            else
            {
                CashRepositoryRow.Visible = false;
                CashRepositoryBalanceRow.Visible = false;
            }
        }

        private void LoadLabels()
        {
            DateLiteral.Text = "<label for='DateTextBox'>" + Resources.Titles.ValueDate + "</label>";
            StoreLiteral.Text = "<label for='StoreDropDownList'>" + Resources.Titles.SelectStore + "</label>";

            PartyLiteral.Text = "<label for='PartyCodeTextBox'>" + Resources.Titles.SelectParty + "</label>";
            PriceTypeLiteral.Text = "<label for='PriceTypeDropDownList'>" + Resources.Titles.PriceType + "</label>";
            ReferenceNumberLiteral.Text = "<label for='ReferenceNumberTextBox'>" + Resources.Titles.ReferenceNumberAbbreviated + "</label>";

            RunningTotalTextBoxLabelLiteral.Text = "<label for ='RunningTotalTextBox'>" + Resources.Titles.RunningTotal + "</label>";
            TaxTotalTextBoxLabelLiteral.Text = "<label for='TaxTotalTextBox'>" + Resources.Titles.TaxTotal + "</label>";
            GrandTotalTextBoxLabelLiteral.Text = "<label for='GrandTotalTextBox'>" + Resources.Titles.GrandTotal + "</label>";
            ShippingAddressDropDownListLabelLiteral.Text = "<label for='ShippingAddressDropDownList'>" + Resources.Titles.ShippingAddress + "</label>";
            ShippingCompanyDropDownListLabelLiteral.Text = "<label for='ShippingCompanyDropDownList'>" + Resources.Titles.ShippingCompany + "</label>";
            ShippingChargeTextBoxLabelLiteral.Text = "<label for='ShippingChargeTextBox'>" + Resources.Titles.ShippingCharge + "</label>";
            CashRepositoryDropDownListLabelLiteral.Text = "<label for='CashRepositoryDropDownList'>" + Resources.Titles.CashRepository + "</label>";
            CashRepositoryBalanceTextBoxLabelLiteral.Text = "<label for='CashRepositoryBalanceTextBox'>" + Resources.Titles.CashRepositoryBalance + "</label>";
            CostCenterDropDownListLabelLiteral.Text = "<label for='CostCenterDropDownList'>" + Resources.Titles.CostCenter + "</label>";
            SalesPersonDropDownListLabelLiteral.Text = "<label for='SalesPersonDropDownList'>" + Resources.Titles.SalesPerson + "</label>";
            StatementReferenceTextBoxLabelLiteral.Text = "<label for='StatementReferenceTextBox'>" + Resources.Titles.StatementReference + "</label>";
        }

        private void LoadTransactionTypeLabel()
        {
            if(this.TransactionType == TranType.Sales)
            {
                TransactionTypeLiteral.Text = "<label>" + Resources.Titles.SalesType + "</label>";
            }
            else
            {
                TransactionTypeLiteral.Text = "<label>" + Resources.Titles.PurchaseType + "</label>";
            }
        }

        private void LoadItems()
        {
            if(this.TransactionType == TranType.Sales)
            {
                ItemDropDownListCascadingDropDown.ServiceMethod = "GetItems";
            }
            else
            {
                ItemDropDownListCascadingDropDown.ServiceMethod = "GetStockItems";
            }
        }

        private void LoadPriceTypes()
        {
            if(this.TransactionType == TranType.Sales)
            {
                MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(PriceTypeDropDownList, "core", "price_types", "price_type_id", MixERP.Net.BusinessLayer.Core.PriceTypes.GetDisplayField());
            }
            else
            {
                PriceTypeLiteral.Visible = false;
                PriceTypeDropDownList.Visible = false;

                ShippingAddressRow.Visible = false;
                ShippingChargeRow.Visible = false;
                ShippingCompanyRow.Visible = false;
            }

        }

        private void LoadSalesPerson()
        {
            SalesPersonRow.Visible = false;

            if(this.TransactionType == TranType.Sales)
            {
                MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(SalesPersonDropDownList, "core", "agents", "agent_id", MixERP.Net.BusinessLayer.Core.Agents.GetDisplayField());
                SalesPersonRow.Visible = true;
            }
        }

        private void LoadShippers()
        {
            ShippingAddressRow.Visible = false;
            ShippingChargeRow.Visible = false;
            ShippingCompanyRow.Visible = false;

            if(this.TransactionType == TranType.Sales)
            {
                if(this.SubType == SubTranType.Direct || this.SubType == SubTranType.Delivery)
                {
                    MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(ShippingCompanyDropDownList, "core", "shippers", "shipper_id", MixERP.Net.BusinessLayer.Core.Shippers.GetDisplayField());

                    ShippingAddressRow.Visible = true;
                    ShippingChargeRow.Visible = true;
                    ShippingCompanyRow.Visible = true;
                }
            }
        }

        private void InitializeControls()
        {
            this.LoadLabels();
            this.LoadTransactionTypeLabel();
            this.LoadItems();
            this.LoadPriceTypes();
            this.LoadShippers();
            this.LoadCostCenters();
            this.LoadSalesPerson();
            this.LoadStores();
            this.LoadCashRepositories();
        }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            if(Request.Form["__EVENTTARGET"] != null)
            {
                Control c = this.Page.FindControl(Request.Form["__EVENTTARGET"]);
                if(c != null)
                {
                    if(c.ID.Equals(UnitDropDownList.ClientID))
                    {
                        UnitDropDownList_SelectedIndexChanged(c, e);
                    }
                }
            }

            //Moved from Page_Init
            this.TitleLabel.Text = this.Text;
            this.Page.Title = this.Text;
            TransactionTypeLiteral.Visible = this.DisplayTransactionTypeRadioButtonList;
            TransactionTypeRadioButtonList.Visible = this.DisplayTransactionTypeRadioButtonList;

            this.SetControlStates();
        }

        private void BindGridView()
        {
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table = this.GetTable();

            ProductGridView.DataSource = table;
            ProductGridView.DataBind();

            this.ShowTotals();
        }

        protected void ShippingChargeTextBox_TextChanged(object sender, EventArgs e)
        {
            this.ShowTotals();

            if(CashRepositoryBalanceRow.Visible)
            {
                CashRepositoryDropDownList.Focus();
                return;
            }

            if(CostCenterRow.Visible)
            {
                CostCenterDropDownList.Focus();
                return;
            }

            StatementReferenceTextBox.Focus();
        }

        private void ShowTotals()
        {
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table = this.GetTable();

            RunningTotalTextBox.Text = (this.GetRunningTotalOfSubTotal(table) + MixERP.Net.Common.Conversion.TryCastDecimal(ShippingChargeTextBox.Text)).ToString(System.Threading.Thread.CurrentThread.CurrentCulture);
            TaxTotalTextBox.Text = this.GetRunningTotalOfTax(table).ToString(System.Threading.Thread.CurrentThread.CurrentCulture);
            GrandTotalTextBox.Text = (this.GetRunningTotalOfTotal(table) + MixERP.Net.Common.Conversion.TryCastDecimal(ShippingChargeTextBox.Text)).ToString(System.Threading.Thread.CurrentThread.CurrentCulture);

        }

        #region "Running Totals"
        private decimal GetRunningTotalOfSubTotal(Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table)
        {
            decimal retVal = 0;

            if(table.Count > 0)
            {
                foreach(MixERP.Net.Common.Models.Transactions.ProductDetailsModel model in table)
                {
                    retVal += MixERP.Net.Common.Conversion.TryCastDecimal(model.Subtotal);
                }
            }

            return retVal;
        }

        private decimal GetRunningTotalOfTax(Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table)
        {
            decimal retVal = 0;

            if(table.Count > 0)
            {
                foreach(MixERP.Net.Common.Models.Transactions.ProductDetailsModel model in table)
                {
                    retVal += MixERP.Net.Common.Conversion.TryCastDecimal(model.Tax);
                }
            }

            return retVal;
        }

        private decimal GetRunningTotalOfTotal(Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table)
        {
            decimal retVal = 0;

            if(table.Count > 0)
            {
                foreach(MixERP.Net.Common.Models.Transactions.ProductDetailsModel model in table)
                {
                    retVal += MixERP.Net.Common.Conversion.TryCastDecimal(model.Total);
                }
            }

            return retVal;
        }
        #endregion

        protected void CashRepositoryDropDownList_SelectIndexChanged(object sender, EventArgs e)
        {
            this.UpdateRepositoryBalance();
        }

        private void UpdateRepositoryBalance()
        {
            if(CashRepositoryBalanceRow.Visible)
            {
                if(CashRepositoryDropDownList.SelectedItem != null)
                {
                    CashRepositoryBalanceTextBox.Text = MixERP.Net.BusinessLayer.Office.CashRepositories.GetBalance(MixERP.Net.Common.Conversion.TryCastInteger(CashRepositoryDropDownList.SelectedItem.Value)).ToString(System.Threading.Thread.CurrentThread.CurrentCulture);
                }
            }
        }

        protected void AddButton_Click(object sender, EventArgs e)
        {
            string itemCode = ItemCodeTextBox.Text;
            string itemName = ItemDropDownList.SelectedItem.Text;
            int quantity = MixERP.Net.Common.Conversion.TryCastInteger(QuantityTextBox.Text);
            string unit = UnitDropDownList.SelectedItem.Text;
            int unitId = MixERP.Net.Common.Conversion.TryCastInteger(UnitDropDownList.SelectedItem.Value);
            decimal itemInStock = 0;
            decimal price = MixERP.Net.Common.Conversion.TryCastDecimal(PriceTextBox.Text);
            decimal discount = MixERP.Net.Common.Conversion.TryCastDecimal(DiscountTextBox.Text);
            decimal taxRate = MixERP.Net.Common.Conversion.TryCastDecimal(TaxRateTextBox.Text);
            decimal tax = MixERP.Net.Common.Conversion.TryCastDecimal(TaxTextBox.Text);
            int storeId = 0;

            if(StoreDropDownList.SelectedItem != null)
            {
                storeId = MixERP.Net.Common.Conversion.TryCastInteger(StoreDropDownList.SelectedItem.Value);
            }

            #region Validation

            if(string.IsNullOrWhiteSpace(itemCode))
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(ItemCodeTextBox);
                return;
            }
            else
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(ItemCodeTextBox);
            }

            if(!MixERP.Net.BusinessLayer.Core.Items.ItemExistsByCode(itemCode))
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(ItemCodeTextBox);
                return;
            }
            else
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(ItemCodeTextBox);
            }

            if(quantity < 1)
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(QuantityTextBox);
                return;
            }
            else
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(QuantityTextBox);
            }

            if(!MixERP.Net.BusinessLayer.Core.Units.UnitExistsByName(unit))
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(UnitDropDownList);
                return;
            }
            else
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(UnitDropDownList);
            }

            if(price <= 0)
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(PriceTextBox);
                return;
            }
            else
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(PriceTextBox);
            }

            if(discount < 0)
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(DiscountTextBox);
                return;
            }
            else
            {
                if(discount > (price * quantity))
                {
                    MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(DiscountTextBox);
                    return;
                }
                else
                {
                    MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(DiscountTextBox);
                }
            }


            if(tax < 0)
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(TaxTextBox);
                return;
            }
            else
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.RemoveDirty(TaxTextBox);
            }

            if(this.VerifyStock)
            {
                if(this.TransactionType == TranType.Sales)
                {
                    if(MixERP.Net.BusinessLayer.Core.Items.IsStockItem(itemCode))
                    {
                        itemInStock = MixERP.Net.BusinessLayer.Core.Items.CountItemInStock(itemCode, unitId, storeId);
                        if(quantity > itemInStock)
                        {
                            MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(QuantityTextBox);
                            ErrorLabel.Text = String.Format(System.Threading.Thread.CurrentThread.CurrentCulture, Resources.Warnings.InsufficientStockWarning, itemInStock.ToString("G29", System.Threading.Thread.CurrentThread.CurrentCulture), UnitDropDownList.SelectedItem.Text, ItemDropDownList.SelectedItem.Text);
                            return;
                        }
                    }
                }
            }
            #endregion

            this.AddRowToTable(itemCode, itemName, quantity, unit, price, discount, taxRate, tax);

            this.BindGridView();
            ItemCodeTextBox.Text = "";
            QuantityTextBox.Text = "1";
            PriceTextBox.Text = "";
            DiscountTextBox.Text = "";
            TaxTextBox.Text = "";

            ItemCodeTextBox.Focus();
        }

        private void AddRowToTable(string itemCode, string itemName, int quantity, string unit, decimal price, decimal discount, decimal taxRate, decimal tax)
        {
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table = this.GetTable();

            decimal amount = price * quantity;
            decimal subTotal = amount - discount;
            decimal total = subTotal + tax;

            MixERP.Net.Common.Models.Transactions.ProductDetailsModel row = new Common.Models.Transactions.ProductDetailsModel();
            row.ItemCode = itemCode;
            row.ItemName = itemName;
            row.Quantity = quantity;
            row.Unit = unit;
            row.Price = price;
            row.Amount = amount;
            row.Discount = discount;
            row.Subtotal = subTotal;
            row.Rate = taxRate;
            row.Tax = tax;
            row.Total = total;

            table.Add(row);
            Session[this.ID] = table;
        }

        private Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> GetTable()
        {
            if(Session[this.ID] != null)
            {
                return (Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel>)Session[this.ID];
            }

            return new Collection<Common.Models.Transactions.ProductDetailsModel>();
        }

        void UnitDropDownList_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.DisplayPrice();
            PriceTextBox.Focus();
        }

        private void DisplayPrice()
        {
            string itemCode = ItemDropDownList.SelectedItem.Value;
            string party = string.Empty;

            int unitId = MixERP.Net.Common.Conversion.TryCastInteger(UnitDropDownList.SelectedItem.Value);

            decimal price = 0;

            if(this.TransactionType == TranType.Sales)
            {
                party = PartyDropDownList.SelectedItem.Value;
                short priceTypeId = MixERP.Net.Common.Conversion.TryCastShort(PriceTypeDropDownList.SelectedItem.Value);
                price = MixERP.Net.BusinessLayer.Core.Items.GetItemSellingPrice(itemCode, party, priceTypeId, unitId);
            }
            else
            {
                party = PartyDropDownList.SelectedItem.Value;
                price = MixERP.Net.BusinessLayer.Core.Items.GetItemCostPrice(itemCode, party, unitId);
            }

            decimal discount = MixERP.Net.Common.Conversion.TryCastDecimal(DiscountTextBox.Text);
            decimal taxRate = MixERP.Net.BusinessLayer.Core.Items.GetTaxRate(itemCode);


            PriceTextBox.Text = price.ToString(System.Threading.Thread.CurrentThread.CurrentCulture);

            TaxRateTextBox.Text = taxRate.ToString(System.Threading.Thread.CurrentThread.CurrentCulture);
            TaxTextBox.Text = (((price - discount) * taxRate) / 100.00m).ToString("#.##", System.Threading.Thread.CurrentThread.CurrentCulture);

            decimal amount = price * MixERP.Net.Common.Conversion.TryCastInteger(QuantityTextBox.Text);

            AmountTextBox.Text = amount.ToString(System.Threading.Thread.CurrentThread.CurrentCulture);
        }

        protected void OKButton_Click(object sender, EventArgs e)
        {
            DateTime valueDate = DateTime.MinValue;
            int storeId = 0;
            string transactionType = string.Empty;
            string partyCode = string.Empty;
            partyCode = PartyDropDownList.SelectedItem.Value;

            if(DateTextBox != null)
            {
                valueDate = MixERP.Net.Common.Conversion.TryCastDate(DateTextBox.Text);
            }

            if(StoreDropDownList.SelectedItem != null)
            {
                storeId = MixERP.Net.Common.Conversion.TryCastInteger(StoreDropDownList.SelectedItem.Value);
            }

            if(TransactionTypeRadioButtonList.SelectedItem != null)
            {
                transactionType = TransactionTypeRadioButtonList.SelectedItem.Value;
            }


            if(string.IsNullOrWhiteSpace(partyCode))
            {
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(PartyCodeTextBox);
                MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(PartyDropDownList);
                PartyCodeTextBox.Focus();
                return;
            }

            if(valueDate.Equals(DateTime.MinValue))
            {
                ErrorLabelTop.Text = Resources.Warnings.InvalidDate;
                DateTextBox.CssClass = "dirty";
                DateTextBox.Focus();
                return;
            }

            if(this.TransactionType == TranType.Sales)
            {
                if(StoreDropDownList.Visible)
                {
                    if(!MixERP.Net.BusinessLayer.Office.Stores.IsSalesAllowed(storeId))
                    {
                        ErrorLabelTop.Text = Resources.Warnings.SalesNotAllowedHere;
                        MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(StoreDropDownList);
                        return;
                    }
                }

                if(TransactionTypeRadioButtonList.Visible)
                {
                    if(transactionType.Equals(Resources.Titles.Credit))
                    {
                        if(!MixERP.Net.BusinessLayer.Core.Parties.IsCreditAllowed(partyCode))
                        {
                            ErrorLabelTop.Text = Resources.Warnings.CreditNotAllowed;
                            return;
                        }
                    }
                }
            }

            ModeHiddenField.Value = "Started";
            this.SetControlStates();
            ItemCodeTextBox.Focus();
        }

        protected void CancelButton_Click(object sender, EventArgs e)
        {
            ModeHiddenField.Value = "";

            Session[this.ID] = null;
            RunningTotalTextBox.Text = "";
            TaxTotalTextBox.Text = "";
            GrandTotalTextBox.Text = "";

            this.SetControlStates();
            this.BindGridView();
        }

        private void SetControlStates()
        {
            bool state = ModeHiddenField.Value.Equals("Started");

            FormPanel.Enabled = state;
            BottomPanel.Enabled = state;
            DateTextBox.Disabled = state;
            StoreDropDownList.Enabled = !state;
            TransactionTypeRadioButtonList.Enabled = !state;
            PartyCodeTextBox.Enabled = !state;
            PartyDropDownList.Enabled = !state;
            PriceTypeDropDownList.Enabled = !state;
            ReferenceNumberTextBox.Enabled = !state;
            OKButton.Enabled = !state;
            CancelButton.Enabled = state;

            if(TransactionTypeRadioButtonList.Visible)
            {
                if(TransactionTypeRadioButtonList.SelectedItem.Value.Equals(Resources.Titles.Credit))
                {
                    CashRepositoryRow.Visible = false;
                    CashRepositoryBalanceRow.Visible = false;
                }
            }

        }
    }
}