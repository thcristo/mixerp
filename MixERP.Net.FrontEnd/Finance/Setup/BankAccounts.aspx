<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="BankAccounts.aspx.cs" Inherits="MixERP.Net.FrontEnd.Finance.Setup.BankAccounts" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
    <style>
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="BankAccountForm" runat="server" 
        Text="<%$Resources:Titles, BankAccounts %>" 
        TableSchema="core" Table="bank_accounts" KeyColumn="account_id"
        ViewSchema="core" View="bank_accounts" Width="1000" PageSize="10" 
        DisplayFields="office.users.user_id-->user_name, core.accounts.account_id-->account_code + ' (' + account_name + ')'"
        DisplayViews="office.users.user_id-->office.user_view, core.accounts.account_id-->core.account_view"        
         />

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
