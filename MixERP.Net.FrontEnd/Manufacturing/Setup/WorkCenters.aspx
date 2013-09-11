<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="WorkCenters.aspx.cs" Inherits="MixERP.Net.FrontEnd.Manufacturing.Setup.WorkCenters" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="WorkCenterForm" runat="server"
        KeyColumn="work_center_id"
        TableSchema="office" Table="work_centers"
        ViewSchema="office" View="work_center_view"
        Width="1000"
        DisplayFields="office.offices.office_id-->office_code + ' (' + office_name + ')' "
        DisplayViews="office.offices.office_id-->office.office_view"
        
         />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
