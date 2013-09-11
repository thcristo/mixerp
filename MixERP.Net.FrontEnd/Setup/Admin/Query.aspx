<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/MenuMaster.Master" AutoEventWireup="true"
    CodeBehind="Query.aspx.cs" Inherits="MixERP.Net.FrontEnd.Setup.Admin.Query" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
    <script src="/Scripts/CodeMirror/lib/codemirror.js"></script>
    <script src="/Scripts/CodeMirror/mode/sql/sql.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
    <link href="/Scripts/CodeMirror/lib/codemirror.css" rel="stylesheet" />
    <link href="/Scripts/CodeMirror/theme/visual-studio.css" rel="stylesheet" />

    <style type="text/css">
        .CodeMirror
        {
            border: 1px solid #eee;
            height: auto;
        }

        .CodeMirror-scroll
        {
            overflow-y: hidden;
            overflow-x: auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <div id="buttons">

        <asp:Button ID="ExecuteButton" runat="server" Text="<%$Resources:Titles, Execute %>" OnClick="ExecuteButton_Click" />
        <asp:Button ID="LoadButton" runat="server" Text="<%$Resources:Titles, Load %>" OnClick="LoadButton_Click" />
        <asp:Button ID="ClearButton" runat="server" Text="<%$Resources:Titles, Clear %>" OnClick="ClearButton_Click" />
        <asp:Button ID="SaveButton" runat="server" Text="<%$Resources:Titles, Save %>" OnClientClick="$('#QueryHidden').val(editor.getValue());" OnClick="SaveButton_Click" />

        <asp:Button ID="RunButton" runat="server" Text="<%$Resources:Titles, Run %>" OnClick="RunButton_Click" />
        <asp:Button ID="LoadCustomerButton" runat="server" Text="Load Customers" OnClick="LoadCustomerButton_Click" />
        <asp:Button ID="LoadSampleData" runat="server" Text="Load Sample Data" OnClick="LoadSampleData_Click" />

        <asp:Button ID="GoToTopButton" runat="server" Text="<%$Resources:Titles, GoToTop %>" OnClientClick="$('html, body').animate({ scrollTop: 0 }, 'slow');return(false);" />
    </div>

    <br />
    <br />
    <br />

    <asp:TextBox ID="QueryTextBox" runat="server" TextMode="MultiLine" Width="1000">
    </asp:TextBox>
    <asp:HiddenField ID="QueryHidden" runat="server" />

    <br />

    <p class="vpad16">
        <div style="width: 100%; max-height: 400px; overflow: auto">
            <asp:GridView ID="SQLGridView" EnableTheming="false" CssClass="grid2" HeaderStyle-CssClass="grid2-header" RowStyle-CssClass="grid2-row" AlternatingRowStyle-CssClass="grid2-row-alt" runat="server" ShowHeaderWhenEmpty="true">
            </asp:GridView>
            <asp:Literal ID="MessageLiteral" runat="server" />
        </div>
    </p>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder"
    runat="server">

    <script type="text/javascript">
        var mime = 'text/x-plsql';

        if (window.location.href.indexOf('mime=') > -1) {
            mime = window.location.href.substr(window.location.href.indexOf('mime=') + 5);
        }

        editor = CodeMirror.fromTextArea(document.getElementById("QueryTextBox"), {
            mode: mime,
            lineNumbers: true,
            matchBrackets: true,
            autoMatchParens: true,
            tabMode: 'spaces',
            tabSize: 4,
            indentUnit: 4,
            viewportMargin: Infinity,

        });

        editor.setOption("theme", "visual-studio");
        editor.refresh();

        $().ready(function () {
            var $scrollingDiv = $("#buttons");

            $(window).scroll(function () {
                $scrollingDiv
                    .stop()
                    .animate({ "marginTop": ($(window).scrollTop()) }, "slow");
            });
        });
    </script>
</asp:Content>

<script runat="server">
    protected void ClearButton_Click(object sender, EventArgs e)
    {
        QueryTextBox.Text = "";
    }
    protected void LoadButton_Click(object sender, EventArgs e)
    {
        this.LoadSQL();
    }

    private void LoadSQL()
    {
        string sql = System.IO.File.ReadAllText(Server.MapPath("~/db/en-US/mixerp.bak.sql"));
        QueryTextBox.Text = sql;
    }


    protected void RunButton_Click(object sender, EventArgs e)
    {
        string sql = System.IO.File.ReadAllText(Server.MapPath("~/db/en-US/mixerp.bak.sql"));
        using(System.Data.DataTable table = MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(new Npgsql.NpgsqlCommand(sql)))
        {
            MessageLiteral.Text = string.Format("<div class='success'>{0} row(s) affected.</div>", table.Rows.Count);
            SQLGridView.DataSource = table;
            SQLGridView.DataBind();
        }
    }

    protected void LoadCustomerButton_Click(object sender, EventArgs e)
    {
        string sql = System.IO.File.ReadAllText(Server.MapPath("~/db/en-US/party-sample.sql"));
        using(System.Data.DataTable table = MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(new Npgsql.NpgsqlCommand(sql)))
        {
            MessageLiteral.Text = string.Format("<div class='success'>{0} row(s) affected.</div>", table.Rows.Count);
            SQLGridView.DataSource = table;
            SQLGridView.DataBind();
        }
    }

    protected void LoadSampleData_Click(object sender, EventArgs e)
    {
        string sql = System.IO.File.ReadAllText(Server.MapPath("~/db/en-US/sample-data.sql"));
        using(System.Data.DataTable table = MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(new Npgsql.NpgsqlCommand(sql)))
        {
            MessageLiteral.Text = string.Format("<div class='success'>{0} row(s) affected.</div>", table.Rows.Count);
            SQLGridView.DataSource = table;
            SQLGridView.DataBind();
        }
    }

    protected void ExecuteButton_Click(object sender, EventArgs e)
    {
        try
        {
            using(System.Data.DataTable table = MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(new Npgsql.NpgsqlCommand(QueryTextBox.Text)))
            {
                MessageLiteral.Text = string.Format("<div class='success'>{0} row(s) affected.</div>", table.Rows.Count);
                SQLGridView.DataSource = table;
                SQLGridView.DataBind();
            }
        }
        catch(Exception ex)
        {
            MessageLiteral.Text = "<div class='error'>" + ex.Message + "</div>";
        }
    }

    protected void SaveButton_Click(object sender, EventArgs e)
    {
        string sql = QueryHidden.Value;

        if(!string.IsNullOrWhiteSpace(sql))
        {
            string path = Server.MapPath("~/db/en-US/mixerp.postgresql.bak.sql");
            System.IO.File.Delete(path);
            System.IO.File.WriteAllText(path, sql, Encoding.UTF8);
        }
    }
</script>