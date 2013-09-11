<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="JournalVoucher.aspx.cs" Inherits="MixERP.Net.FrontEnd.Finance.JournalVoucher" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <AjaxCTK:ToolkitScriptManager ID="ScriptManager1" runat="server" />
    <asp:Label ID="TitleLabel" runat="server" Text="<%$Resources:Titles, JournalVoucherEntry %>" CssClass="title" />



    <asp:UpdateProgress ID="UpdateProgress1" runat="server">
        <ProgressTemplate>
            <div class="ajax-container">
                <img alt="progress" src="/spinner.gif" class="ajax-loader" />
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server" ChildrenAsTriggers="true" UpdateMode="Always">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="AddButton" />
        </Triggers>
        <ContentTemplate>

            <div class="vpad8">
                <div class="form" style="width: 272px;">
                    <table>
                        <tr>
                            <td>
                                <asp:Literal ID="ValueDateLiteral" runat="server" />
                            </td>
                            <td>
                                <asp:Literal ID="ReferenceNumberLiteral" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <mixerp:DateTextBox ID="ValueDateTextBox" runat="server" Width="100" CssClass="date" />
                            </td>
                            <td>
                                <asp:TextBox ID="ReferenceNumberTextBox" runat="server" Width="100" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <asp:GridView ID="TransactionGridView" runat="server" EnableTheming="False"
                CssClass="grid2" ShowHeaderWhenEmpty="true" AutoGenerateColumns="false"
                OnRowDataBound="TransactionGridView_RowDataBound"
                OnRowCommand="TransactionGridView_RowCommand"
                Width="1000">
                <Columns>
                    <asp:BoundField DataField="AccountCode" HeaderText="<%$ Resources:Titles, AccountCode %>" HeaderStyle-Width="110" />
                    <asp:BoundField DataField="Account" HeaderText="<%$ Resources:Titles, Account %>" HeaderStyle-Width="250" />
                    <asp:BoundField DataField="CashRepository" HeaderText="<%$ Resources:Titles, CashRepository %>" HeaderStyle-Width="100" />
                    <asp:BoundField DataField="StatementReference" HeaderText="<%$ Resources:Titles, StatementReference %>" HeaderStyle-Width="320" />
                    <asp:BoundField DataField="Debit" HeaderText="<%$ Resources:Titles, Debit %>" HeaderStyle-Width="70" />
                    <asp:BoundField DataField="Credit" HeaderText="<%$ Resources:Titles, Credit %>" HeaderStyle-Width="70" />

                    <asp:TemplateField ShowHeader="False" HeaderText="<%$ Resources:Titles, Action %>">
                        <ItemTemplate>
                            <asp:ImageButton ID="DeleteImageButton" ClientIDMode="Predictable" runat="server"
                                CausesValidation="false"
                                OnClientClick="return(confirmAction());"
                                ImageUrl="~/Resource/Icons/delete-16.png" />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
                <AlternatingRowStyle CssClass="grid2-row-alt" />
                <HeaderStyle CssClass="grid2-header" />
                <RowStyle CssClass="grid2-row" />
            </asp:GridView>

            <div class="grid3">
                <table class="valignmiddle">
                    <tr>
                        <td>
                            <asp:TextBox ID="AccountCodeTextBox" runat="server" Width="100"
                                onblur="selectItem(this.id, 'AccountDropDownList');" ToolTip="Alt + C" />
                        </td>
                        <td>
                            <asp:DropDownList ID="AccountDropDownList" runat="server" Width="250"
                                onchange="document.getElementById('AccountCodeTextBox').value = this.options[this.selectedIndex].value;if(this.selectedIndex == 0) { return false };"
                                ToolTip="Ctrl + A" />

                            <AjaxCTK:CascadingDropDown ID="AccountDropDownListCascadingDropDown" runat="server"
                                TargetControlID="AccountDropDownList" Category="Account" ServiceMethod="GetAccounts"
                                ServicePath="~/Services/AccountData.asmx"
                                LoadingText="<%$Resources:Labels, Loading %>"
                                PromptText="<%$Resources:Titles, Select %>">
                            </AjaxCTK:CascadingDropDown>


                        </td>
                        <td>
                            <asp:DropDownList ID="CashRepositoryDropDownList" runat="server" Width="100" />

                            <AjaxCTK:CascadingDropDown ID="CashRepositoryDropDownListCascadingDropDown" runat="server"
                                ParentControlID="AccountDropDownList" TargetControlID="CashRepositoryDropDownList"
                                Category="CashRepository" ServiceMethod="GetCashRepositories"
                                ServicePath="~/Services/AccountData.asmx"
                                LoadingText="<%$Resources:Labels, Loading %>"
                                PromptText="<%$Resources:Titles, Select %>">
                            </AjaxCTK:CascadingDropDown>
                        </td>
                        <td>
                            <asp:TextBox ID="StatementReferenceTextBox" runat="server" Width="315"
                                ToolTip="Ctrl + S" />
                        </td>
                        <td>
                            <asp:TextBox ID="DebitTextBox" runat="server" Width="62"
                                ToolTip="Ctrl + D" onfocus="getDebit();" />
                        </td>
                        <td>
                            <asp:TextBox ID="CreditTextBox" runat="server" Width="62"
                                ToolTip="Ctrl + R" onfocus="getCredit();" />
                        </td>
                        <td>
                            <asp:Button ID="AddButton" runat="server" Text="<%$Resources:Titles, Add %>" Width="60" Height="24" OnClick="AddButton_Click" />
                        </td>
                    </tr>
                </table>
            </div>

            <div class="vpad8">
                <div class="form" style="width: 400px;">
                    <table>
                        <tr>
                            <td>
                                <asp:Literal ID="CostCenterLiteral" runat="server" />
                            </td>
                            <td>
                                <asp:DropDownList ID="CostCenterDropDownList" runat="server" Width="250" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Literal ID="DebitTotalLiteral" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox ID="DebitTotalTextBox" runat="server" ReadOnly="true" Width="140" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Literal ID="CreditTotalLiteral" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox ID="CreditTotalTextBox" runat="server" ReadOnly="true" Width="140" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                            </td>
                            <td>
                                <asp:Button ID="PostTransactionButton" runat="server" Text="<%$Resources:Titles, PostTransaction %>" CssClass="button" Height="30" Width="120" OnClick="PostTransactionButton_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
    <script type="text/javascript">
        areYouSureLocalized = '<%= Resources.Questions.AreYouSure %>';

        $(document).ready(function () {
            shortcut.add("ALT+C", function () {
                $('#AccountCodeTextBox').focus();
            });

            shortcut.add("CTRL+A", function () {
                $('#AccountDropDownList').focus();
            });

            shortcut.add("CTRL+S", function () {
                $('#StatementReferenceTextBox').focus();
            });

            shortcut.add("CTRL+D", function () {
                $('#DebitTextBox').focus();
            });

            shortcut.add("CTRL+R", function () {
                $('#CreditTextBox').focus();
            });

            shortcut.add("CTRL+ENTER", function () {
                $('#AddButton').click();
            });
        });

        var getDebit = function () {
            var drTotal = parseFloat2($("#DebitTotalTextBox").val());
            var crTotal = parseFloat2($("#CreditTotalTextBox").val());
            var debitTextBox = $("#DebitTextBox");
            var creditTextBox = $("#CreditTextBox");

            if (crTotal > drTotal) {
                if (debitTextBox.val() == '' && creditTextBox.val() == '') {
                    debitTextBox.val(crTotal - drTotal);
                }
            }
        }

        var getCredit = function () {
            var drTotal = parseFloat2($("#DebitTotalTextBox").val());
            var crTotal = parseFloat2($("#CreditTotalTextBox").val());
            var debitTextBox = $("#DebitTextBox");
            var creditTextBox = $("#CreditTextBox");

            if (drTotal > crTotal) {
                if (debitTextBox.val() == '' && creditTextBox.val() == '') {
                    creditTextBox.val(drTotal - crTotal);
                }
            }
        }

    </script>
</asp:Content>
