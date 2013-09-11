<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="AgentBonusSlabDetails.aspx.cs" Inherits="MixERP.Net.FrontEnd.Sales.Setup.AgentBonusSlabDetails" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="BonusSlabDetailsForm" runat="server" DenyAdd="false" DenyDelete="false" DenyEdit="false" KeyColumn="bonus_slab_detail_id"
        PageSize="10" TableSchema="core" Table="bonus_slab_details" ViewSchema="core" View="bonus_slab_detail_view" 
        Text="<%$Resources:Titles, BonusSlabDetails %>" Width="1000"
        DisplayFields="core.bonus_slabs.bonus_slab_id-->bonus_slab_name"
        DisplayViews="core.bonus_slabs.bonus_slab_id-->core.bonus_slabs"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
