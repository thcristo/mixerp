/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.UserControls.Products
{
    /// <summary>
    /// Stay warned, this is very very big class and maybe complex as well and needs improvements.
    /// This UserControl provides a common interface for all transactions that are related to
    /// stock and/or inventory. Everything is handled in this class, except for the Save event.
    /// The save event is exposed to the page containing this control and should be handled there.
    /// </summary>
    public partial class ProductControl : System.Web.UI.UserControl
    {
        /// <summary>
        /// Transaction book for products are Sales and Purchase.
        /// </summary>
        public MixERP.Net.Common.Models.Transactions.TranBook Book { get; set; }
 
        /// <summary>
        /// Sub transaction books are maintained for breaking down the Purchase and Sales transaction into smaller steps
        /// such as Quotations, Orders, Deliveries, e.t.c.
        /// </summary>
        public MixERP.Net.Common.Models.Transactions.SubTranBook SubBook { get; set; }
     
        /// <summary>
        /// The title displayed in the form.
        /// </summary>
        public string Text { get; set; }

        /// <summary>
        /// A readonly instance of the GridView
        /// </summary>
        //public GridView Grid { get { return ProductGridView; } }

        /// <summary>
        /// This property when set to true will display the RadioButtonList control which contains the transaction types.
        /// Transaction types are Cash and Credit.
        /// </summary>
        public bool DisplayTransactionTypeRadioButtonList { get; set; }

        /// <summary>
        /// This property when set to true will verify the stock against the credit inventory transactions or "Sales".
        /// Since negative stock is not allowed, you will not be able to add a product to the grid.
        /// This property must be enabled for Sales transaction which affect the available inventory on hand.
        /// Please also note that even when this property is enabled, the products having the switch "Maintain Stock" set to "Off"
        /// will not be checked for stock availability.
        /// This property should be disabled or set to false for stock transactions that do not affect stock such as "Quotations", "Orders", e.t.c.
        /// </summary>
        public bool VerifyStock { get; set; }

        /// <summary>
        /// This property when enabled will display cash repositories and their available balance.
        /// Not all availble cash repositories will be displayed here but those which belong to the current (or logged in) branch office.
        /// This property must be enabled for transactions which have affect on cash ledger, namely "Direct Purchase" and "Direct Sales".
        /// </summary>
        public bool ShowCashRepository { get; set; }

        /// <summary>
        /// This property is used to temporarily store pre assigned instance of transactions for merging transactions
        /// and creating a batch transactions.
        /// Some cases:
        /// Multiple Sales Quotations --> Sales Order.
        /// Multiple Sales Quotations --> Sales Delivery.
        /// </summary>
        private MixERP.Net.Common.Models.Transactions.MergeModel model = new Common.Models.Transactions.MergeModel();

        /// <summary>
        /// This class is a representation of the controls in this UserControl.
        /// </summary>
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

        /// <summary>
        /// This function returns a new instance of ControlCollection class.
        /// </summary>
        /// <returns></returns>
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

        /// <summary>
        /// This property provides a read-only acess to all the controls of this UserControl.
        /// This property is accessed after the user clicks the "Save" button.
        /// The values of each control is read and then sent to the database layer.
        /// </summary>
        public ControlCollection GetForm
        {
            get
            {
                return this.GetControls();
            }
        }

        /// <summary>
        /// This property set the width of the top panel.
        /// </summary>
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


        /// <summary>
        /// This event will be raised on SaveButon's click event.
        /// </summary>
        public event EventHandler SaveButtonClick;

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            //Validation Check Start

            //Check the number of products in the grid.
            if(ProductGridView.Rows.Count.Equals(0))
            {
                ErrorLabel.Text = Resources.Warnings.NoItemFound;
                return;
            }

            //If this is a purchase on cash transaction, we need to make sure
            //that the selected cash repository has enough balance for the credit transaction.
            //Remember: 
            //1. MixERP does not allow negative cash transaction.
            //2. Cash is maintained on LIFO principal.

            //The MixERP LIFO principal

            //LAST IN
            //The cash would be in at last --> Last In. 
            //This means that you would have to first approve a transaction which has cash on the debit side before it shows up in the effective balance. 
            //If you approve the transaction, cash is in-->Last In.
            //If you reject or ignore the transaction, there is no effect.

            //FIRST OUT
            //The cash would be out at first --> First Out.
            //This means that even when you have not approved a transaction which has cash on the credit side, it reduces the cash balance. 
            //So, if you approve the transaction, there is no effect since the cash was already out-->First Out. 
            //The actual cash balance is restored only when you reject the transaction.
 
            //So, no point on getting confused here. This calculations is happened on the database level.
            //If anything goes wrong, throw stones to your DBAs.

            if(this.Book == Common.Models.Transactions.TranBook.Purchase && CashRepositoryRow.Visible)
            {
                //Update cash repository balance.
                this.UpdateRepositoryBalance();

                //Get the balance of the cash repository.
                decimal repositoryBalance = MixERP.Net.Common.Conversion.TryCastDecimal(CashRepositoryBalanceTextBox.Text);

                //Get the grand total credit amount.
                decimal grandTotal = MixERP.Net.Common.Conversion.TryCastDecimal(GrandTotalTextBox.Text);

                //If the amount to pay is greater than available cash balance.
                if(grandTotal > repositoryBalance)
                {
                    //Display an error message to the user stating that there's not enough cash to post this transaction.
                    ErrorLabel.Text = Resources.Warnings.NotEnoughCash;
                    return;
                }
            }

            //Check if the shipping charge textbox has a value.
            if(!string.IsNullOrWhiteSpace(ShippingChargeTextBox.Text))
            {
               //Check if the value actually was a number.
                if(!MixERP.Net.Common.Conversion.IsNumeric(ShippingChargeTextBox.Text))
                {
                    //You could never guess in your wildest dream how insanse a user could behave.
                    MixERP.Net.BusinessLayer.Helpers.FormHelper.MakeDirty(ShippingChargeTextBox);
                    return;
                }
            }
            //Validation Check End
            //I am happy now.

            //Now exposing the button click event.
            this.OnSaveButtonClick(sender, e);
        }

        /// <summary>
        ///This method when called will raise a "SaveButtonClick" event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        public virtual void OnSaveButtonClick(object sender, EventArgs e)
        {
            //Check if the event can be used.
            if (SaveButtonClick != null)
            {
                //Raise the event.
                this.SaveButtonClick(sender, e);
            }
        }


        /// <summary>
        /// This method handles the grid view's row command event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void ProductGridView_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            //We only expect a delete command here.
            //Be careful if this GridView implements other commands in the future.
            //Needs refactoring.


            //Get an instance of the collection of the products stored in the grid.
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> table = this.GetTable();

            //Get the instance of grid view row on which the the command was triggered.
            GridViewRow row = (GridViewRow)(((ImageButton)e.CommandSource).NamingContainer);

            //Get the index of the row.
            int index = row.RowIndex;

            //Remove the product from the collection at the specified index.
            table.RemoveAt(index);

            //Store the new product collection on the session.
            Session[this.ID] = table;

            //Call the method to bind the gridview once again. 
            this.BindGridView();

            //UpdatePanel1.Update();
        }

        /// <summary>
        /// This method is called for each grid view rows' databound event.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void ProductGridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //Check the row type.
            if(e.Row.RowType == DataControlRowType.DataRow)
            {
                //Yeaaaaa! This is a data row. Yipeee!!!!!
                
                //Find the image button in this row.
                ImageButton deleteImageButton = e.Row.FindControl("DeleteImageButton") as ImageButton;
                
                //Make sure that we found the image button we were looking for.
                if (deleteImageButton != null)
                {
                    //Wowowowow, we found the button.

                    //Tell the script manager that this button should fire an asynchronous postback event.
                    ScriptManager.GetCurrent(this.Page).RegisterAsyncPostBackControl(deleteImageButton);
                }
            }
        }

        #region "Page Initialization"
        protected void Page_Init(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                this.ClearSession(this.ID);
            }

            this.InitializeControls();
            this.LoadValuesFromSession();
            this.BindGridView();
            ScriptManager1.RegisterAsyncPostBackControl(ProductGridView);
        }


        private void LoadValuesFromSession()
        {
            if(Session["Product"] == null)
            {
                return;
            }

            model = Session["Product"] as MixERP.Net.Common.Models.Transactions.MergeModel;

            if(model == null)
            {
                return;
            }

            PartyDropDownListCascadingDropDown.SelectedValue = model.PartyCode.ToString();

            if(PriceTypeDropDownList.SelectedItem != null)
            {
                MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.SetSelectedValue(PriceTypeDropDownList, model.PriceTypeId.ToString());
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
            if(this.SubBook == Common.Models.Transactions.SubTranBook.Direct || this.SubBook == Common.Models.Transactions.SubTranBook.Invoice || this.SubBook == Common.Models.Transactions.SubTranBook.Delivery || this.SubBook == Common.Models.Transactions.SubTranBook.Receipt)
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
            if(this.SubBook == Common.Models.Transactions.SubTranBook.Direct || this.SubBook == Common.Models.Transactions.SubTranBook.Invoice || this.SubBook == Common.Models.Transactions.SubTranBook.Delivery || this.SubBook == Common.Models.Transactions.SubTranBook.Receipt)
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
            if(this.Book == Common.Models.Transactions.TranBook.Sales)
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
            if(this.Book == Common.Models.Transactions.TranBook.Sales)
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
            if(this.Book == Common.Models.Transactions.TranBook.Sales)
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

            if(this.Book == Common.Models.Transactions.TranBook.Sales)
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

            if(this.Book == Common.Models.Transactions.TranBook.Sales)
            {
                if(this.SubBook == Common.Models.Transactions.SubTranBook.Direct || this.SubBook == Common.Models.Transactions.SubTranBook.Delivery)
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
                if(this.Book == Common.Models.Transactions.TranBook.Sales)
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
                //Get an instance of the ProductDetailsModel collection stored in session.
                var productCollection = (Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel>)Session[this.ID];

                //Summate the collection.
                productCollection = SummateProducts(productCollection);

                //Store the summated table in session.
                Session[this.ID] = productCollection;

                return productCollection;
            }

            return new Collection<Common.Models.Transactions.ProductDetailsModel>();
        }

        private Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> SummateProducts(Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> productCollection)
        {
            //Create a new collection of products.
            Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> collection = new Collection<Common.Models.Transactions.ProductDetailsModel>();

            //Iterate through the supplied product collection.
            foreach(MixERP.Net.Common.Models.Transactions.ProductDetailsModel product in productCollection)
            {
                //Create a product
                MixERP.Net.Common.Models.Transactions.ProductDetailsModel productInCollection = null;

                if(collection.Count > 0)
                {
                    productInCollection = collection.Where(x => x.ItemCode == product.ItemCode && x.ItemName == product.ItemName && x.Unit == product.Unit && x.Price == product.Price && x.Rate == product.Rate).FirstOrDefault();
                }

                if(productInCollection == null)
                {
                    collection.Add(product);
                }
                else
                {
                    productInCollection.Quantity += product.Quantity;
                    productInCollection.Amount += product.Amount;
                    productInCollection.Discount += product.Discount;
                    productInCollection.Subtotal += product.Subtotal;
                    productInCollection.Tax += product.Tax;
                    productInCollection.Total += product.Total;
                }
            }

            return collection;
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

            if(this.Book == Common.Models.Transactions.TranBook.Sales)
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

            if(this.Book == Common.Models.Transactions.TranBook.Sales)
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