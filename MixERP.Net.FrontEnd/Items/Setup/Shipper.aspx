<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Shipper.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.Shipper" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="ShipperForm" runat="server" Text="<%$Resources:Titles, Shippers %>" TableSchema="core" Table="shippers" KeyColumn="shipper_id"
        ViewSchema="core" View="shippers" Width="5000" PageSize="10"
        Exclude="shipper_code, shipper_name"
        SelectedValues="core.accounts.account_id-->'20110 (Shipping Charge Payable)'"
        DisplayFields="core.accounts.account_id-->account_code + ' (' + account_name + ')'"
        DisplayViews="core.accounts.account_id-->core.account_view"
        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
