<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProductViewControl.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.Products.ProductViewControl" %>
<asp:Panel ID="GridPanel" runat="server" Width="1024px" ScrollBars="Auto">
    <asp:GridView
        ID="SalesQuotationGridView"
        runat="server"
        CssClass="grid"
        Width="1424px"
        AutoGenerateColumns="false"
        OnRowDataBound="SalesQuotationGridView_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <a href="#" title="Preview">
                        <img src="../Resource/Icons/search-16.png" />
                    </a>
                    <a href="#" title="Go To Top">
                        <img src="../Resource/Icons/top-16.png" />
                    </a>
                    <a href="#">
                    </a>
                    <a href="#">
                    </a>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:CheckBox ID="SelectCheckBox" runat="server" ClientIDMode="Predictable" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="id" HeaderText="id" />
            <asp:BoundField DataField="value_date" HeaderText="value_date" DataFormatString="{0:d}" />
            <asp:BoundField DataField="office" HeaderText="office" />
            <asp:BoundField DataField="reference_number" HeaderText="reference_number" />
            <asp:BoundField DataField="party" HeaderText="party" />
            <asp:BoundField DataField="price_type" HeaderText="price_type" />
            <asp:BoundField DataField="transaction_ts" HeaderText="transaction_ts" DataFormatString="{0:D}" />
            <asp:BoundField DataField="user" HeaderText="user" />
            <asp:BoundField DataField="statement_reference" HeaderText="statement_reference" />
        </Columns>
    </asp:GridView>
</asp:Panel>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {        
        using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Transactions.NonGLStockTransaction.GetView("Sales.Quotation"))
        {
            SalesQuotationGridView.DataSource = table;            
            SalesQuotationGridView.DataBind();

        }
    }

    protected void SalesQuotationGridView_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if(e.Row.RowType == DataControlRowType.Header)
        {
            for(int i = 0; i < e.Row.Cells.Count; i++)
            {
                string cellText = e.Row.Cells[i].Text.Replace("&nbsp;", " ").Trim();

                if(!string.IsNullOrWhiteSpace(cellText))
                {
                    cellText = MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("FormResource", cellText);
                    e.Row.Cells[i].Text = cellText;
                }
            }
        }

        if(e.Row.RowType == DataControlRowType.DataRow)
        {
            //e.Row.Cells[2].Text = string.Format(e.Row.Cells[2].Text, "{0:dd/MM/yyyy}");
        }
    }    
</script>

<script type="text/javascript">
    $('#SalesQuotationGridView tr').click(function () {
        console.log('Grid row was clicked. Now, searching the radio button.');
        var checkBox = $(this).find('td input:checkbox')
        console.log('The check box was found.');
        toogleSelection(checkBox.attr("id"));
    });

    var toogleSelection = function (id) {
        var attribute = $("#" + id).attr("checked");
        if (attribute) {
            $("#" + id).removeAttr("checked");
        }
        else {
            $("#" + id).attr("checked", "checked");
        }

        console.log('Radio button "' + id + '" selected.');
    }
</script>