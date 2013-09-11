<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="CostPrices.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.CostPrices" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="ItemCostPriceForm" runat="server" Text="<%$Resources:Titles, ItemCostPrices %>" TableSchema="core" Table="item_cost_prices" KeyColumn="item_cost_price_id"
        ViewSchema="core" View="item_cost_price_view" Width="1000" PageSize="10"
        DisplayFields="core.items.item_id-->item_code + ' (' + item_name + ')', core.parties.party_id-->party_code + ' (' + party_name + ')', core.units.unit_id-->unit_code + ' (' + unit_name + ')' "
        DisplayViews="core.items.item_id-->core.item_view, core.parties.party_id-->core.party_view, core.units.unit_id-->core.unit_view"        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
