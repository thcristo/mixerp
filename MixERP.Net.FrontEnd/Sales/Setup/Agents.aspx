<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Agents.aspx.cs" Inherits="MixERP.Net.FrontEnd.Sales.Setup.Agents" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="AgentSlabForm" runat="server" DenyAdd="false" DenyDelete="false" DenyEdit="false" KeyColumn="agent_id"
        PageSize="10" TableSchema="core" Table="agents" ViewSchema="core" View="agent_view" 
        Text="<%$Resources:Titles, AgentSetup %>" Width="1000"
        DisplayFields="core.accounts.account_id-->account_code + ' (' + account_name + ')'"
        DisplayViews="core.accounts.account_id-->core.account_view"
        SelectedValues="core.accounts.account_id-->'20100 (Accounts Payable)'"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
