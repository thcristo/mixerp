<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="DeliveryWithoutOrder.aspx.cs" Inherits="MixERP.Net.FrontEnd.Sales.Confirmation.DeliveryWithoutOrder" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:TransactionChecklist runat="server"
        DisplayWithdrawButton="true"
        DisplayViewInvoiceButton="true"
        DisplayEmailInvoiceButton="true"
        DisplayCustomerInvoiceButton="true"
        DisplayPrintReceiptButton="true"
        DisplayPrintGLEntryButton="true"
        DisplayAttachmentButton="true"
        InvoicePath="~/Sales/Confirmation/ReportDelivery.aspx"
        CustomerInvoicePath="~/Sales/Confirmation/ReportDeliveryNote.aspx"
        GLAdvicePath="~/Finance/Confirmation/GLAdvice.aspx"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
