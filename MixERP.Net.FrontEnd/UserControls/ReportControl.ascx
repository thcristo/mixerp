<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ReportControl.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.ReportControl" %>
<asp:HiddenField ID="ReportHidden" runat="server" />
<asp:HiddenField ID="ReportTitleHidden" runat="server" />

<div class="report-command hide">
    <asp:ImageButton ID="SendEmailImageButton" runat="server" ImageUrl="~/Resource/Icons/email-16.png" />
    <a href="javascript:window.print();">
        <img src="/Resource/Icons/print-16.png" />
    </a>
    <asp:ImageButton ID="ExcelImageButton" runat="server" ImageUrl="~/Resource/Icons/excel-16.png" OnClientClick="$('#ReportHidden').val(getPageHTML())" OnClick="ExcelImageButton_Click" />
    <asp:ImageButton ID="WordImageButton" runat="server" ImageUrl="~/Resource/Icons/word-16.png" OnClientClick="$('#ReportHidden').val(getPageHTML())" OnClick="WordImageButton_Click" />

    <a href="javascript:window.scrollTo(0, 0);">
        <img src="/Resource/Icons/top-16.png" />
    </a>
    <a href="javascript:window.scrollTo(0,document.body.scrollHeight);">
        <img src="/Resource/Icons/bottom-16.png" />
    </a>
    <a onclick="$('.report-parameter').toggle(500);" href="#">
        <img src="/Resource/Icons/filter-16.png" />
    </a>
    <a onclick="window.close();" href="#">
        <img src="/Resource/Icons/close-16.png" />
    </a>
</div>

<div id="report">
    <mixerp:ReportHeader runat="server" />

    <h1>
        <asp:Literal ID="ReportTitleLiteral" runat="server" />
    </h1>
    <div>
        <asp:Literal ID="TopSectionLiteral" runat="server" />


        <asp:PlaceHolder ID="BodyPlaceHolder" runat="server">
            <asp:Literal ID="ContentLiteral" runat="server"></asp:Literal>
        </asp:PlaceHolder>
        <asp:Literal ID="BottomSectionLiteral" runat="server" />
    </div>
</div>

<script type="text/javascript">
    function getPageHTML() {
      return "<html>" + $("#report").html() + "</html>";
    }
</script>
