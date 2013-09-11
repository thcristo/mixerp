<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="COA.aspx.cs" Inherits="MixERP.Net.FrontEnd.Finance.Setup.COA" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="AccountTypeForm" runat="server" 
        Text="<%$Resources:Titles, ChartOfAccounts %>" 
        TableSchema="core" Table="accounts" KeyColumn="account_id"
        ViewSchema="core" View="account_view" Width="1500" PageSize="10" 
        Exclude="sys_type"
        DisplayFields="core.account_masters.account_master_id-->account_master_code + ' (' + account_master_name + ')',core.accounts.account_id-->account_code + ' (' + account_name + ')'" 
        DisplayViews="core.account_masters.account_master_id-->core.account_masters, core.accounts.account_id--> core.account_view" 
        
        />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
