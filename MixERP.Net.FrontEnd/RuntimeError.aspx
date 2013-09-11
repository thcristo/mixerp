<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="RuntimeError.aspx.cs" Inherits="MixERP.Net.FrontEnd.RuntimeError" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <h1>Error Occurred</h1>
    <hr class="hr" />

    <p>We tried our best to complete the task, but it failed miserably.</p>

    <br />
    <p>You could notify the project admin if you think this is a serious error. Nonetheless, the exception has been logged and we might be able to help you.</p>

    <br />

    <asp:Literal ID="ExceptionLiteral" runat="server" />
<br />
    <p>
        <a class="menu" href="javascript:history.go(-1);">Go Back to the Previous Page</a>
    </p>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>