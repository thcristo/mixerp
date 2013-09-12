<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="CashRepositories.aspx.cs" Inherits="MixERP.Net.FrontEnd.Setup.CashRepositories" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="CashRepositoryForm" runat="server"
        DenyAdd="false" DenyDelete="false" DenyEdit="false"
        KeyColumn="cash_repository_id"
        PageSize="10" Width="1000"
        TableSchema="office" Table="cash_repositories"
        ViewSchema="office" View="cash_repository_view"
        Text="<%$Resources:Titles, CashRepositories %>"
        DisplayFields="office.cash_repositories.cash_repository_id-->cash_repository_code + ' (' + cash_repository_name + ')', office.offices.office_id-->office_code + ' (' + office_name + ')'"
        DisplayViews="office.cash_repositories.cash_repository_id-->office.cash_repository_view, office.offices.office_id-->office.office_view"        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
