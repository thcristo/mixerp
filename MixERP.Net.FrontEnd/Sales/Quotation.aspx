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
        <table class="valignmiddle" style="border-collapse: collapse;">
            <tr>
                <td>
                    <asp:LinkButton ID="AddNewLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, AddNew %>"
                        OnClientClick="window.location='/Sales/Entry/Quotation.aspx';return false;" />

                    <asp:LinkButton 
                        ID="MergeToSalesOrderLinkButton" 
                        runat="server" 
                        CssClass="menu" 
                        Text="<%$Resources:Titles, MergeBatchToSalesOrder %>" 
                        OnClientClick="return getSelectedItems();" />
                    <asp:LinkButton ID="MergeToSalesDeliveryLinkButton" runat="server" CssClass="menu" Text="<%$Resources:Titles, MergeBatchToSalesDelivery %>" />
                </td>
                <td>
                    <a href="#" class="menu" id="flagButton">Flag This Transaction</a>
                </td>
            </tr>
        </table>


        <div id="flag-popunder" style="position: absolute; width: 300px; display: none;" class="popunder">
            <h3>Flag This Transaction</h3>
            <hr class="hr" />

            <div class="note">
                You can mark this transaction with a flag, however you will not be able to see the flags created by other users.                
            </div>
            <br />
            <p>Please select a flag</p>
            <p>
                <asp:DropDownList ID="FlagDropDownList" runat="server" Width="300px">
                </asp:DropDownList>
            </p>
            <p>
                <asp:Button ID="UpdateButton" runat="server" Text="Udate" CssClass="menu" />
                <a href="#" onclick="$('#flag-popunder').toggle(500);" class="menu">Close</a>
            </p>
        </div>


    </div>
    <asp:Label ID="ErrorLabel" runat="server" CssClass="error" Text="Cannot merge quotations of multiple parties into a batch. Please try again." />

    <mixerp:ProductView runat="server" />

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
    <script type="text/javascript">

        var getSelectedItems = function() {
            var selection = [];

            //Get the grid instance.
            var grid = $("#ProductViewGridView");

            //Set the position of the column which contains the checkbox.
            var checkBoxColumnPosition = "2";

            //Set the position of the column which contains id.
            var idColumnPosition = "3";

            //Iterate through each row to investigate the selection.
            grid.find("tr").each(function () {

                //Get an instance of the current row in this loop.
                var row = $(this);

                //Get the instance of the cell which contains the checkbox.
                var checkBoxContainer = row.select("td:nth-child(" + checkBoxColumnPosition + ")");

                //Get the instance of the checkbox from the container.
                var checkBox = checkBoxContainer.find("input");

                if (checkBox) {
                    //Check if the checkbox was selected or checked.
                    if(checkBox.attr("checked") == "checked")
                    {
                        //Get ID from the associated cell.
                        var id = row.find("td:nth-child(" + idColumnPosition + ")").html();

                        //Add the ID to the array.
                        selection.push(id);
                    }
                }
            });

            //alert(selection.join(','));

            return false;
        }

        //Get FlagButton instance.
        var flagButton = $("#flagButton");

        flagButton.click(function () {
            //Get flag div instance which will be displayed under the button.
            var popunder = $("#flag-popunder");

            //Get FlagButton's position and height information.
            var left = $(this).position().left;
            var top = $(this).position().top;
            var height = $(this).height();

            //Margin in pixels.
            var margin = 12;

            popunder.css("left", left);
            popunder.css("top", top + height + margin);
            popunder.show(500);
        });

    </script>
</asp:Content>

<script runat="server">
    protected void Page_Init()
    {
        MixERP.Net.BusinessLayer.Helpers.DropDownListHelper.BindDropDownList(FlagDropDownList, "core", "flag_types", "flag_type_id", "flag_type_name");
    }
</script>