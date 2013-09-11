<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Items.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.Items" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="ItemForm" runat="server" 
        Text="<%$Resources:Titles, Items %>" TableSchema="core" Table="items" KeyColumn="item_id"
        ViewSchema="core" View="items" Width="2000" PageSize="10"
        DisplayFields="core.item_groups.item_group_id-->item_group_code + ' (' + item_group_name + ')', core.brands.brand_id-->brand_code + ' (' + brand_name + ')', core.parties.party_id-->party_code + ' (' + party_name + ')', core.units.unit_id-->unit_code + ' (' + unit_name + ')', core.taxes.tax_id-->tax_code + ' (' + tax_name + ')'"
        DisplayViews="core.item_groups.item_group_id-->core.item_groups, core.brands.brand_id-->core.brands, core.parties.party_id-->core.party_view, core.units.unit_id-->core.unit_view, core.taxes.tax_id-->core.tax_view"
        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
