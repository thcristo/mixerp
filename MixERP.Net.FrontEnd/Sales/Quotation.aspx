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
        <table class="valignmiddle" style="border-collapse:collapse;">
            <tr>
                <td>
                    <asp:LinkButton ID="AddNewLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, AddNew %>"
                        OnClientClick="window.location='/Sales/Entry/Quotation.aspx';return false;" />

                    <asp:LinkButton ID="MergeToSalesOrderLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, MergeBatchToSalesOrder %>" />
                    <asp:LinkButton ID="MergeToSalesDeliveryLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, MergeBatchToSalesDelivery %>" />
                </td>
                <td>
                    <ul id="menu2">
                        <li>
                            <a href="" class="menu">Select a Flag</a>
                            <ul>
                                <li>
                                    <a style="background-color:#D61D04!important;" class="dropdown" href="#">Important</a></li>
                                <li>
                                    <a style="background-color:#EB0CDC!important;" class="dropdown" href="#">Critical</a></li>
                                <li>
                                    <a style="background-color:#A11CD6!important;" class="dropdown" href="#">Review</a>
                                </li>
                                <li>
                                    <a style="background-color:#B4BA07!important;"  class="dropdown" href="#">Todo</a>
                                </li>
                                <li>
                                    <a style="background-color:#8DC41D!important;" class="dropdown" href="#">OK</a>
                                </li>
                                <li>
                                    <a class="dropdown" href="#">Select a Flag</a></li>
                                <li>
                            </ul>
                        </li>
                    </ul>
                </td>
            </tr>
        </table>

    </div>
    <asp:Label ID="ErrorLabel" runat="server" CssClass="error" Text="Cannot merge quotations of multiple parties into a batch. Please try again." />

    <mixerp:ProductView runat="server" />

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
