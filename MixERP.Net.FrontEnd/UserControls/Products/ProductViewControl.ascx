<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="True" CodeBehind="ProductViewControl.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.Products.ProductViewControl" %>
<AjaxCTK:ToolkitScriptManager ID="ScriptManager1" runat="server" />
<div id="filter" class="vpad8">
    <table class="form">
        <tr>
            <td>
                Date From
            </td>
            <td>
                Date To
            </td>
            <td>
                Office
            </td>
            <td>
                Party
            </td>
            <td>
                Price Type
            </td>
            <td>
                User
            </td>
            <td>
                Reference Number
            </td>
            <td>
                Statement Reference
            </td>
            <td>
            </td>
        </tr>
        <tr>
            <td>
                <mixerp:DateTextBox ID="DateFromDateTextBox" runat="server" CssClass="date" Width="72px" Mode="MonthStartDate" />
            </td>
            <td>
                <mixerp:DateTextBox ID="DateToDateTextBox" runat="server" CssClass="date" Width="72px" Mode="MonthEndDate" />
            </td>
            <td>
                <asp:TextBox ID="OfficeTextBox" runat="server" Width="72px" />
            </td>
            <td>
                <asp:TextBox ID="PartyTextBox" runat="server" Width="72px" />
            </td>
            <td>
                <asp:TextBox ID="PriceTypeTextBox" runat="server" Width="72px" />
            </td>
            <td>
                <asp:TextBox ID="UserTextBox" runat="server" Width="72px" />
            </td>
            <td>
                <asp:TextBox ID="ReferenceNumberTextBox" runat="server" Width="150px" />
            </td>
            <td>
                <asp:TextBox ID="StatementReferenceTextBox" runat="server" Width="150px" />
            </td>
            <td>
                <asp:Button ID="ShowButton" runat="server" Text="Show" CssClass="button" Width="50px" OnClick="ShowButton_Click" />
            </td>
        </tr>
    </table>
</div>
<asp:Panel ID="GridPanel" runat="server" Width="1024px" ScrollBars="Auto">
    <asp:GridView
        ID="SalesQuotationGridView"
        runat="server"
        CssClass="grid"
        Width="1424px"
        AutoGenerateColumns="false"
        OnRowDataBound="SalesQuotationGridView_RowDataBound">
        <Columns>
            <asp:TemplateField HeaderStyle-Width="56px" HeaderText="actions">
                <ItemTemplate>
                    <a href="#" id="PreviewAnchor" runat="server" title="Quick Preview" class="preview">
                        <img src="/Resource/Icons/search-16.png" />
                    </a>
                    <a href="#" id="PrintAnchor" runat="server" title="Print">
                        <img src="/Resource/Icons/print-16.png" />
                    </a>
                    <a href="#" title="Go To Top" onclick="window.scroll(0);">
                        <img src="/Resource/Icons/top-16.png" />
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
            <asp:BoundField DataField="flag_color" HeaderText="flag_color" />
        </Columns>
    </asp:GridView>
</asp:Panel>


<script runat="server">
    protected void Page_Init(object sender, EventArgs e)
    {
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        this.LoadGridView();
    }

    protected void ShowButton_Click(object sender, EventArgs e)
    {
        this.LoadGridView();
    }

    private void LoadGridView()
    {
        DateTime dateFrom = MixERP.Net.Common.Conversion.TryCastDate(DateFromDateTextBox.Text);
        DateTime dateTo = MixERP.Net.Common.Conversion.TryCastDate(DateToDateTextBox.Text);
        string office = OfficeTextBox.Text;
        string party = PartyTextBox.Text;
        string priceType = PriceTypeTextBox.Text;
        string user = UserTextBox.Text;
        string referenceNumber = ReferenceNumberTextBox.Text;
        string statementReference = StatementReferenceTextBox.Text;

        using(System.Data.DataTable table = MixERP.Net.BusinessLayer.Transactions.NonGLStockTransaction.GetView("Sales.Quotation", dateFrom, dateTo, office, party, priceType, user, referenceNumber, statementReference))
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
            string id = e.Row.Cells[2].Text;

            if(!string.IsNullOrWhiteSpace(id))
            {
                string popUpQuotationPreviewUrl = "/Sales/Confirmation/ReportSalesQuotation.aspx?TranId=" + id;

                HtmlAnchor previewAnchor = (HtmlAnchor)e.Row.Cells[0].FindControl("PreviewAnchor");
                if(previewAnchor != null)
                {
                    previewAnchor.HRef = popUpQuotationPreviewUrl;
                }

                HtmlAnchor printAnchor = (HtmlAnchor)e.Row.Cells[0].FindControl("PrintAnchor");
                if(printAnchor != null)
                {
                    printAnchor.Attributes.Add("onclick", "showWindow('" + popUpQuotationPreviewUrl + "');return false;");
                }
            }
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



    $(document).ready(function () {
        shortcut.add("ALT+O", function () {
            $('#OfficeTextBox').foucs();
        });

        shortcut.add("CTRL+ENTER", function () {
            $('#ShowButton').click();
        });
    });



    function DropDown(el) {
        this.dd = el;
        this.placeholder = this.dd.children('span');
        this.opts = this.dd.find('ul.dropdown > li');
        this.val = '';
        this.index = -1;
        this.initEvents();
    }

    DropDown.prototype = {
        initEvents: function () {
            var obj = this;

            obj.dd.on('click', function (event) {
                $(this).toggleClass('active');
                event.stopPropagation();
            });

            obj.opts.on('click', function (e) {
                var opt = $(this);
                obj.val = opt.text();
                obj.index = opt.index();
                obj.placeholder.text(obj.val);
            });
        },

        getValue: function () {
            return this.val;
        },
        getIndex: function () {
            return this.index;
        }
    }

    $(function () {

        var dd = new DropDown($('#dd'));

        $(document).click(function () {
            // all dropdowns
            $('.wrapper-dropdown-5').removeClass('active');
        });

    });
</script>
