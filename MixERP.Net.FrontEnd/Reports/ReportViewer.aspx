<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportViewer.aspx.cs" Inherits="MixERP.Net.FrontEnd.Reports.ReportViewer" ValidateRequest="false" %>

<%@ Import Namespace="MixERP.Net.BusinessLayer.Helpers" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="/Scripts/jquery.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">

    <asp:Panel runat="server" ID="ReportParameterPanel" class="report-parameter hide">
        <asp:Table ID="ReportParameterTable" runat="server" />
        <a href="#" onclick="$('.report-parameter').toggle(500);" class="menu" style="float: right; padding: 4px;">Close This Form</a>
    </asp:Panel>

    <mixerp:Report ID="ReportViewer1" runat="server" />
    </form>
</body>
</html>