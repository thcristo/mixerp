<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="CostCenters.aspx.cs" Inherits="MixERP.Net.FrontEnd.Finance.Setup.CostCenters" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="CostCenterForm" runat="server"
        DenyAdd="false" DenyDelete="false" DenyEdit="false"
        KeyColumn="cost_center_id"
        PageSize="10" Width="1100"
        TableSchema="office" Table="cost_centers"
        ViewSchema="office" View="cost_center_view"
        Text="<%$Resources:Titles, CostCenters %>" />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
