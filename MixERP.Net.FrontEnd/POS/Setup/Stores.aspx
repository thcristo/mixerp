<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Stores.aspx.cs" Inherits="MixERP.Net.FrontEnd.POS.Setup.Stores" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="StoreForm" runat="server" DenyAdd="false" DenyDelete="false" DenyEdit="false" KeyColumn="store_id"
        PageSize="10" TableSchema="office" Table="stores" ViewSchema="office" View="stores" Text="<%$Resources:Titles, Stores %>" Width="1000"
        DisplayFields="office.store_types.store_type_id-->store_type_name,office.offices.office_id-->office_name"        
        DisplayViews="office.store_types.store_type_id-->office.store_types,office.offices.office_id-->office.office_view"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
