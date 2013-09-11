<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="ItemGroups.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.ItemGroups" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="ItemGroupForm" runat="server" Text="<%$Resources:Titles, ItemGroups %>" TableSchema="core" Table="item_groups" KeyColumn="item_group_id"
        ViewSchema="core" View="item_groups" Width="1000" PageSize="10"
        DisplayFields="core.taxes.tax_id-->tax_name"
        DisplayViews="core.taxes.tax_id-->core.tax_view"
        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
