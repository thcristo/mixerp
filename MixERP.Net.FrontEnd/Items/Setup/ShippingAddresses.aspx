<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="ShippingAddresses.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.ShippingAddresses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="BrandForm" runat="server" Text="<%$Resources:Titles, ShippingAddressMaintenance %>" 
        TableSchema="core" Table="shipping_addresses" KeyColumn="shipping_address_id"
        ViewSchema="core" View="shipping_address_view" Width="1000" 
        Exclude="shipping_address_code"
        DisplayFields="core.parties.party_id-->party_code + ' (' + party_name + ')' "
        DisplayViews="core.parties.party_id-->core.party_view"
        PageSize="10"/>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
