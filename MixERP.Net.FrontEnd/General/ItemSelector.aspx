
<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ItemSelector.aspx.cs" Inherits="MixERP.Net.FrontEnd.General.ItemSelector" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="~/themes/purple/main.css" rel="stylesheet" type="text/css" runat="server" />
    <script src="/Scripts/jquery.min.js" type="text/javascript"></script>
    <style type="text/css">
        html, body, form
        {
            height: 100%;
        }

        form
        {
            background-color: white!important;
            padding:12px;
        }

        .grid td, .grid th
        {
            white-space: nowrap;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div class="vpad8">
            <table class="valignmiddle">
                <tr>
                    <td>
                        <asp:DropDownList ID="FilterDropDownList" runat="server" Width="172"
                            DataTextField="column_name" DataValueField="column_name"
                            OnDataBound="FilterDropDownList_DataBound">
                        </asp:DropDownList>
                    </td>
                    <td>
                        <asp:TextBox ID="FilterTextBox" runat="server">
                        </asp:TextBox>
                    </td>
                    <td>
                        <asp:Button ID="GoButton" runat="server" CssClass="button" Text="<%$Resources:Titles, Go %>" Height="25" OnClick="GoButton_Click" />
                    </td>
                </tr>
            </table>
        </div>

        <asp:Panel ID="GridPanel" runat="server" ScrollBars="Auto" Width="900">
            <asp:GridView ID="SearchGridView" runat="server"
                GridLines="None"
                CssClass="grid"
                PagerStyle-CssClass="gridpager"
                RowStyle-CssClass="row"
                AlternatingRowStyle-CssClass="alt"
                AutoGenerateColumns="true"
                OnRowDataBound="SearchGridView_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="<%$Resources:Titles, Select %>">
                        <HeaderTemplate>
                            <asp:Literal ID="SelectLiteral" runat="server" Text="<%$Resources:Titles, Select %>" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <a href="#" class="linkbutton" onclick='updateValue("<%# (Container.DataItem as System.Data.DataRowView)[0].ToString() %>");'>
                                <asp:Literal ID="SelectLiteral2" runat="server" Text="<%$Resources:Titles, Select %>" /></a>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </asp:Panel>
    </div>

        <script type="text/javascript">
            function getParameterByName(name) {
                name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
                var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                    results = regex.exec(location.search);
                return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
            }

            function updateValue(val) {
                var ctl = getParameterByName('AssociatedControlId');
                $('#' + ctl, parent.document.body).val(val);
                parent.jQuery.colorbox.close();
            }
        </script>
            <script type="text/javascript">
                document.onkeydown = function (evt) {
                    evt = evt || window.event;
                    if (evt.keyCode == 27) {
                        top.close();
                    }
                };
    </script>
    </form>
</body>
</html>