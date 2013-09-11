<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/MenuMaster.Master" AutoEventWireup="true" CodeBehind="Index.aspx.cs" Inherits="MixERP.Net.FrontEnd.Dashboard.Index" %>

<%@ Register Assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" Namespace="System.Web.UI.DataVisualization.Charting" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">

    <script src="/Scripts/gridster/jquery.gridster.js"></script>
    <link href="/Scripts/gridster/jquery.gridster.min.css" rel="stylesheet" />
    <script type="text/javascript">
        var gridster;

        $(function () {

            gridster = $(".gridster > ul").gridster({
                widget_margins: [10, 10],
                widget_base_dimensions: [116, 122],
                min_cols: 2
            }).data('gridster');

        });
    </script>
    <style type="text/css">
        ul, ol
        {
            list-style: none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">

    <div style="width: 1092px; margin: auto;">
        <h1 style="margin-left: 12px;">Binod, Welcome to MixERP Dashboard (Todo Page)</h1>

        <div class="gridster ready">
            <ul style="position: relative;">
                <li data-row="1" data-col="1" data-sizex="4" data-sizey="2" class="gs_w">
                    <mixerp:SalesByOfficeWidget runat="server" />
                </li>
                <li data-row="1" data-col="2" data-sizex="4" data-sizey="2" class="gs_w">
                    <mixerp:CurrentOfficeSalesByMonthWidget runat="server" />
                </li>
                <li data-row="2" data-col="1" data-sizex="2" data-sizey="2" class="gs_w">
                    <mixerp:WorkflowWidget runat="server" />
                </li>
                <li data-row="2" data-col="2" data-sizex="2" data-sizey="2" data-sizey="1" class="gs_w">
                    <mixerp:OfficeInformationWidget runat="server" />
                </li>
                <li data-row="2" data-col="3" data-sizex="2" data-sizey="2" class="gs_w">
                    <mixerp:AlertsWidget runat="server" />
                </li>
                <li data-row="2" data-col="4" data-sizex="2" data-sizey="2" class="gs_w">
                    <mixerp:LinksWidget runat="server" />
                </li>
                <li data-row="3" data-col="1" data-sizex="4" data-sizey="2" class="gs_w">
                    <mixerp:TopSellingProductOfAllTimetWidget runat="server" />
                </li>
                <li data-row="3" data-col="2" data-sizex="4" data-sizey="2" class="gs_w">
                    <mixerp:TopSellingProductOfAllTimeCurrentWidget runat="server" />
                </li>
            </ul>
        </div>

        <div class="vpad16">
            <asp:Button ID="SavePositionButton"
                runat="server"
                Text="Save Position"
                Style="margin-left: 12px;"
                CssClass="button" />

            <asp:Button ID="ResetPositionButton"
                runat="server"
                Text="Reset Position"
                CssClass="button" />

            <asp:Button ID="GoToWidgetManagerButton"
                runat="server"
                Text="Go to Widget Manager (Todo: Admin Only)"
                CssClass="button" />

        </div>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
