<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Flags.aspx.cs" Inherits="MixERP.Net.FrontEnd.Setup.Flags" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="FlagForm" runat="server"
        DenyAdd="false" DenyDelete="false" DenyEdit="false"
        KeyColumn="flag_type_id"
        PageSize="10" Width="1000"
        TableSchema="core" Table="flag_types"
        ViewSchema="core" View="flag_types"
        Text="<%$Resources:Titles, Flags %>" />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
    <script type="text/javascript">

        //This event will be called by ASP.net AJAX during
        //asynchronous partial page rendering.
        function pageLoad(sender, args) {

            //At this point, the GridView should have already been reloaded.
            //So, load color information on the grid once again.
            loadColor();
        }

        $(document).ready(function () {
            loadColor();
        });

        var loadColor = function ()
        {
            //Get an instance of the form grid.

            var grid = $("#FormGridView");

            //Set position of the column which contains color value.

            var colorColumnPosition = "4";

            //Iterate through all the rows of the grid.

            grid.find("tr").each(function () {

                //Get the current row instance from the loop.

                var row = $(this);

                //Read the color value from the associated column.

                var color = row.find("td:nth-child(" + colorColumnPosition + ")").html();

                if (color) {

                    //Paint the entire row with the color.

                    row.css("background", color);
                }

                //Iterate through all the columns of the current row.

                row.find("td").each(function () {

                    //Border on each cell would look really ugly.
                    //Prevent border display by unsetting the border information for each cell.

                    $(this).css("border", "none");
                });

            });
        }
    </script>
</asp:Content>
