<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignIn.aspx.cs" Inherits="MixERP.Net.FrontEnd.SignIn" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="themes/purple/main.css" rel="stylesheet" type="text/css" />
    <script src="Scripts/jquery.min.js"></script>
    <title>Sign In</title>
</head>
<body>
    <form id="form1" runat="server">
    <div class="sign-in-logo">
        <a href="/SignIn.aspx">
            <img src="themes/purple/mixerp-logo.png" />
        </a>
    </div>
    <div class="sign-in">
        <h1>
            <asp:Literal ID="SignInLiteral" runat="server" Text="<%$Resources:Titles, SignIn %>" />
        </h1>
        <hr />
        <table width="100%">
            <tr>
                <td style="width: 100px;">
                    <label for="UserIdTextBox">
                        <asp:Literal ID="UserIdLiteral" runat="server" Text="<%$Resources:Titles, UserId %>" />
                    </label>
                </td>
                <td>
                    <p>
                        <asp:TextBox ID="UserIdTextBox" runat="server" />
                    </p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="PasswordTextBox">
                        <asp:Literal ID="PasswordLiteral" runat="server" Text="<%$Resources:Titles, Password %>" />
                    </label>
                </td>
                <td>
                    <p>
                        <asp:TextBox ID="PasswordTextBox" runat="server" TextMode="Password" />
                    </p>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="BranchDropDownList">
                        <asp:Literal ID="SelectBranchLiteral" runat="server" Text="<%$Resources:Titles, SelectYourBranch  %>" />
                    </label>
                </td>
                <td>
                    <asp:DropDownList ID="BranchDropDownList" runat="server" DataSourceID="ObjectDataSource1"
                        DataTextField="office_name" DataValueField="office_id">
                    </asp:DropDownList>
                    <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" SelectMethod="GetOffices"
                        TypeName="MixERP.Net.BusinessLayer.Office.Offices"></asp:ObjectDataSource>
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <p>
                        <asp:CheckBox ID="RememberMe" runat="server" Text="<%$Resources:Titles, RememberMe %>" />
                    </p>
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <asp:Literal ID="MessageLiteral" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <p>
                        <asp:Button ID="SignInButton" runat="server" Text="<%$Resources:Titles, SignIn %>" OnClick="SignInButton_Click" />
                    </p>
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <p>
                        <asp:LinkButton ID="CantAccessAccountLinkButton" runat="server" Text="<%$Resources:Questions, CantAccessAccount %>" />
                    </p>
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
        $("#UserIdTextBox").val('binod');
        $("#PasswordTextBox").val('binod');
    </script>
    </form>
</body>
</html>
