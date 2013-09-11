<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DateTextBox.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.DateTextBox" %>
<asp:TextBox ID="TextBox1" runat="server" Width="100">
</asp:TextBox>
<AjaxCTK:CalendarExtender ID="CalendarExtender1" runat="server" />
<br />
<asp:CompareValidator ID="CompareValidator1" runat="server" Display="Dynamic" />

