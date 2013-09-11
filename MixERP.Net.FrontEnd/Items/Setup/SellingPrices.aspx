<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="SellingPrices.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.SellingPrices" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="ItemSellingPriceForm" runat="server" Text="<%$Resources:Titles, ItemSellingPrices %>" TableSchema="core" Table="item_selling_prices" KeyColumn="item_selling_price_id"
        ViewSchema="core" View="item_selling_price_view" Width="1000" PageSize="10"
        DisplayFields="core.items.item_id-->item_code + ' (' + item_name + ')', core.party_types.party_type_id-->party_type_code + ' (' + party_type_name + ')', core.price_types.price_type_id-->price_type_code + ' (' + price_type_name + ')', core.units.unit_id-->unit_code + ' (' + unit_name + ')' "
        DisplayViews="core.items.item_id-->core.item_view, core.party_types.party_type_id-->core.party_types, core.price_types.price_type_id-->core.price_types, core.units.unit_id-->core.unit_view"
        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
