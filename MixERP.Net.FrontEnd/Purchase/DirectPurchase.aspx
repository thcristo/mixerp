<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="DirectPurchase.aspx.cs" Inherits="MixERP.Net.FrontEnd.Purchase.DirectPurchase" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Product runat="server" ID="DirectPurchaseControl"
        TransactionType="Purchase"
        SubType="Direct"
        Text="<%$Resources:Titles, DirectPurchase %>"
        DisplayTransactionTypeRadioButtonList="true"
        ShowCashRepository="true"
        OnSaveButtonClick="Purchase_SaveButtonClick"
        TopPanelWidth="750px"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
