<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Quotation.aspx.cs" Inherits="MixERP.Net.FrontEnd.Sales.Quotation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <h1>
        <asp:Literal ID="TitleLiteral" runat="server" Text="<%$Resources:Titles, SalesQuotation %>" />
    </h1>
    <hr class="hr" />

    <div class="vpad12">
        <asp:LinkButton ID="AddNewLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, AddNew %>"
            OnClientClick="window.location='/Sales/Entry/Quotation.aspx';return false;" />
        <asp:LinkButton ID="FlagLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, FlagSelection %>" />
        <asp:LinkButton ID="MergeToSalesOrderLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, MergeBatchToSalesOrder %>" />
        <asp:LinkButton ID="MergeToSalesDeliveryLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, MergeBatchToSalesDelivery %>" />
    </div>

    <mixerp:ProductView runat="server" />

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
