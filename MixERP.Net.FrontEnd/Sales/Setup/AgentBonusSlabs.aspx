<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="AgentBonusSlabs.aspx.cs" Inherits="MixERP.Net.FrontEnd.Sales.Setup.AgentBonusSlabs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="BonusSlabForm" runat="server" DenyAdd="false" DenyDelete="false" DenyEdit="false" KeyColumn="bonus_slab_id"
        PageSize="10" TableSchema="core" Table="bonus_slabs" ViewSchema="core" View="bonus_slab_view" 
        Text="<%$Resources:Titles, AgentBonusSlabs %>" Width="1000"
        DisplayFields="core.frequencies.frequency_id-->frequency_name"
        DisplayViews="core.frequencies.frequency_id-->core.frequencies"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
