<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="VoucherVerification.aspx.cs" Inherits="MixERP.Net.FrontEnd.Setup.Policy.VoucherVerification" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="VoucherVerificationPolicyForm" runat="server"
        Text="<%$ Resources:Titles, VoucherVerificationPolicy %>"
        DisplayFields="office.users.user_id-->user_name"
        DisplayViews="office.users.user_id-->office.user_view"
        PageSize="100" Width="2000"
        TableSchema="policy" Table="voucher_verification_policy" KeyColumn="user_id"
        ViewSchema="policy" View="voucher_verification_policy_view"
        />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>