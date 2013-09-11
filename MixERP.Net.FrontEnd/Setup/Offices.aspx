<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Offices.aspx.cs" Inherits="MixERP.Net.FrontEnd.Setup.Offices" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="OfficeForm" runat="server" 
        DenyAdd="false" DenyDelete="true" DenyEdit="true" 
        KeyColumn="office_id" 
        PageSize="10" 
        TableSchema="office" Table="offices" 
        ViewSchema="office" View="offices" 
        Text="<%$Resources:Titles, OfficeSetup %>" 
        DisplayFields="office.offices.office_id-->office_name, core.currencies.currency_code-->currency_symbol + ' (' + currency_code + '/' + currency_name + ')'"
        DisplayViews="office.offices.office_id-->office.office_view, core.currencies.currency_code-->core.currencies"
        Width="4000" />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
