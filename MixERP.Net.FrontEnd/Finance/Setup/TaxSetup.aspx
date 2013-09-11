<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="TaxSetup.aspx.cs" Inherits="MixERP.Net.FrontEnd.Finance.Setup.TaxSetup" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="TaxForm" runat="server" Text="<%$Resources:Titles, TaxSetup %>" TableSchema="core" Table="taxes" KeyColumn="tax_id"
        ViewSchema="core" View="tax_view" Width="1000" PageSize="10" 
        SelectedValues="core.accounts.account_id-->'20700 (Tax Payables)' "
        DisplayFields="core.tax_types.tax_type_id-->tax_type_code + ' (' + tax_type_name + ')', core.accounts.account_id-->account_code + ' (' + account_name + ')'"
        DisplayViews="core.tax_types.tax_type_id-->core.tax_types, core.accounts.account_id-->core.account_view"
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
