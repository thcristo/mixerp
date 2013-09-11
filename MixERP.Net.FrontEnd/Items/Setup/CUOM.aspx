<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="CUOM.aspx.cs" Inherits="MixERP.Net.FrontEnd.Items.Setup.CUOM" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="CompoundUnitForm" runat="server" DenyAdd="false" DenyDelete="false" DenyEdit="false" KeyColumn="compound_unit_id"
        PageSize="10" TableSchema="core" Table="compound_units" ViewSchema="core" View="compound_unit_view" 
        Text="<%$Resources:Titles, CompoundUnitsOfMeasure %>" Width="1000"
        DisplayFields="core.units.unit_id-->unit_name"
        DisplayViews="core.units.unit_id-->core.unit_view"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
