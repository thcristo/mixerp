<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TransactionChecklistControl.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.TransactionChecklistControl" %>
<h1>
    <asp:Literal ID="TitleLiteral" runat="server" Text="<%$Resources:Titles, TransactionPostedSuccessfully %>" />
</h1>
<hr class="hr" />

<asp:Label ID="VerificationLabel" runat="server" />


<br />

<div style="float: left;">
    <h2>
        <asp:Literal ID="ChecklistLiteral" runat="server" Text="<%$Resources:Titles, Checklists %>" />
    </h2>
    <div class="transaction-confirmation" style="margin-top: 12px;">
        <asp:LinkButton ID="WithdrawButton" runat="server" Text="<%$Resources:Titles, WithdrawThisTransaction %>" OnClientClick="$('#withdraw').toggle(200);return(false);" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="ViewInvoiceButton" runat="server" Text="<%$Resources:Titles, ViewThisInvoice %>" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="EmailInvoiceButton" runat="server" Text="<%$Resources:Titles, EmailThisInvoice %>" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="CustomerInvoiceButton" runat="server" Text="<%$Resources:Titles, PrintThisInvoice %>" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="PrintReceiptButton" runat="server" Text="<%$Resources:Titles, PrintReceipt %>" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="PrintGLButton" runat="server" Text="<%$Resources:Titles, PrintGLEntry %>" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="AttachmentButton" runat="server" Text="<%$Resources:Titles, UploadAttachmentForThisTransaction %>" CssClass="linkblock" CausesValidation="false" />
        <asp:LinkButton ID="BackButton" runat="server" Text="<%$Resources:Titles, Back %>" OnClientClick="javascript:history.go(-1);return false;" CssClass="linkblock" CausesValidation="false" />
    </div>
</div>

<div id="withdraw" style="float: left; margin-left: 12px; display: none;">
    <h2>
        <asp:Literal ID="WithdrawTransactionLiteral" runat="server" Text="<%$Resources:Titles, WithdrawTransaction %>" />
    </h2>

    <div class="transaction-confirmation" style="margin-top: 12px;">
        <p>
            <asp:Literal ID="ReasonLiteral" runat="server" Text="<%$Resources:Titles, WithdrawalReason %>" />
        </p>
        <p>
            <asp:TextBox ID="ReasonTextBox" runat="server" TextMode="MultiLine" Width="96%" Height="120" />
        </p>
        <p>
            <asp:RequiredFieldValidator ID="ReasonTextBoxRequired" runat="server" ControlToValidate="ReasonTextBox" ErrorMessage="<%$Resources:Labels, FieldRequired %>" CssClass="form-error" Display="Dynamic" />
        </p>

        <p>
            <asp:Button ID="OKButton" runat="server" Text="<%$Resources:Titles, OK %>" CssClass="button" OnClick="OKButton_Click" />
            <asp:Button ID="CancelButton" runat="server" Text="<%$Resources:Titles, Cancel %>" CssClass="button" CausesValidation="false" OnClientClick="$('#withdraw').toggle(200);return(false);" />
        </p>

    </div>
</div>

<div style="clear: both;"></div>

<asp:Label ID="MessageLabel" runat="server" />


<script runat="server">
    public bool DisplayWithdrawButton { get; set; }
    public bool DisplayViewInvoiceButton { get; set; }
    public bool DisplayEmailInvoiceButton { get; set; }
    public bool DisplayCustomerInvoiceButton { get; set; }
    public bool DisplayPrintReceiptButton { get; set; }
    public bool DisplayPrintGLEntryButton { get; set; }
    public bool DisplayAttachmentButton { get; set; }
    public bool IsNonGLTransaction { get; set; }
    public string InvoicePath { get; set; }
    public string CustomerInvoicePath { get; set; }
    public string GLAdvicePath { get; set; }

    protected void OKButton_Click(object sender, EventArgs e)
    {

        DateTime transactionDate = DateTime.Now;
        long transactionMasterId = MixERP.Net.Common.Conversion.TryCastLong(this.Request["TranId"]);

        MixERP.Net.Common.Models.Transactions.VerificationModel model = MixERP.Net.BusinessLayer.Transactions.Verification.GetVerificationStatus(transactionMasterId);
        if(
            model.Verification.Equals(0) //Awaiting verification 
            ||
            model.Verification.Equals(2) //Automatically Approved by Workflow
            )
        {
            //Withdraw this transaction.                        
            if(transactionMasterId > 0)
            {
                if(MixERP.Net.BusinessLayer.Transactions.Verification.WithdrawTransaction(transactionMasterId, MixERP.Net.BusinessLayer.Helpers.SessionHelper.UserId(), ReasonTextBox.Text))
                {
                    MessageLabel.Text = string.Format(Resources.Labels.TransactionWithdrawnMessage, transactionDate.ToShortDateString());
                    MessageLabel.CssClass = "success vpad12";
                }
            }
        }
        else
        {
            MessageLabel.Text = Resources.Warnings.CannotWithdrawTransaction;
            MessageLabel.CssClass = "error vpad12";
        }

        this.ShowVerificationStatus();
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        WithdrawButton.Visible = this.DisplayWithdrawButton;
        ViewInvoiceButton.Visible = this.DisplayViewInvoiceButton;
        EmailInvoiceButton.Visible = this.DisplayEmailInvoiceButton;
        CustomerInvoiceButton.Visible = this.DisplayCustomerInvoiceButton;
        PrintReceiptButton.Visible = this.DisplayPrintReceiptButton;
        PrintGLButton.Visible = this.DisplayPrintGLEntryButton;
        AttachmentButton.Visible = this.DisplayAttachmentButton;

        string invoiceUrl = ResolveUrl(this.InvoicePath + "?TranId=" + this.Request["TranId"]);
        string customerInvoiceUrl = ResolveUrl(this.CustomerInvoicePath + "?TranId=" + this.Request["TranId"]);
        string glAdviceUrl = ResolveUrl(this.GLAdvicePath + "?TranId=" + this.Request["TranId"]);

        ViewInvoiceButton.Attributes.Add("onclick", "showWindow('" + invoiceUrl + "');return false;");
        CustomerInvoiceButton.Attributes.Add("onclick", "showWindow('" + customerInvoiceUrl + "');return false;");
        PrintGLButton.Attributes.Add("onclick", "showWindow('" + glAdviceUrl + "');return false;");

        this.ShowVerificationStatus();
    }

    private void ShowVerificationStatus()
    {
        long transactionMasterId = MixERP.Net.Common.Conversion.TryCastLong(this.Request["TranId"]);
        MixERP.Net.Common.Models.Transactions.VerificationModel model = MixERP.Net.BusinessLayer.Transactions.Verification.GetVerificationStatus(transactionMasterId);

        switch(model.Verification)
        {
            case -3:
                VerificationLabel.CssClass = "info pink";
                VerificationLabel.Text = string.Format(Resources.Labels.VerificationRejectedMessage, model.VerifierName, model.VerifiedDate.ToString(), model.VerificationReason);
                break;
            case -2:
                VerificationLabel.CssClass = "info red";
                VerificationLabel.Text = string.Format(Resources.Labels.VerificationClosedMessage, model.VerifierName, model.VerifiedDate.ToString(), model.VerificationReason);
                break;
            case -1:
                VerificationLabel.Text = string.Format(Resources.Labels.VerificationWithdrawnMessage, model.VerifierName, model.VerifiedDate.ToString(), model.VerificationReason);
                VerificationLabel.CssClass = "info yellow";
                break;
            case 0:
                VerificationLabel.Text = Resources.Labels.VerificationAwaitingMessage;
                VerificationLabel.CssClass = "info purple";
                break;
            case 1:
            case 2:
                VerificationLabel.Text = string.Format(Resources.Labels.VerificationApprovedMessage, model.VerifierName, model.VerifiedDate.ToString());
                VerificationLabel.CssClass = "info green";
                break;
        }
    }

</script>
