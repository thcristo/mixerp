<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CurrentOfficeSalesByMonthWidget.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.Widgets.CurrentOfficeSalesByMonthWidget" %>
<div class="panel double-panel">
    <div class="panel-title">
        Sales By Month (In Thousands) (Todo: Admin Only)
    </div>
    <div class="panel-content">

        <asp:Chart runat="server" ID="ctl01" Height="212px" Width="442px">
            <Series>
                <asp:Series Name="PES-NY-BK (Brooklyn Branch)" ChartType="FastLine" BorderWidth="5" Color="GreenYellow">
                    <Points>
                        <asp:DataPoint AxisLabel="Jan" YValues="50" />
                        <asp:DataPoint AxisLabel="Feb" YValues="30" />
                        <asp:DataPoint AxisLabel="Mar" YValues="45" />
                        <asp:DataPoint AxisLabel="Apr" YValues="35" />
                        <asp:DataPoint AxisLabel="May" YValues="66" />
                        <asp:DataPoint AxisLabel="Jun" YValues="70" />
                        <asp:DataPoint AxisLabel="Jul" YValues="74" />
                        <asp:DataPoint AxisLabel="Aug" YValues="45" />
                        <asp:DataPoint AxisLabel="Sep" YValues="85" />
                        <asp:DataPoint AxisLabel="Oct" YValues="90" />
                        <asp:DataPoint AxisLabel="Nov" YValues="92" />
                        <asp:DataPoint AxisLabel="Dec" YValues="95" />
                    </Points>
                </asp:Series>
            </Series>
            <Legends>
                <asp:Legend Docking="Top" />
            </Legends>
            <ChartAreas>
                <asp:ChartArea Name="ChartArea1" BorderColor="Green" BackColor="Green">
                    <AxisX Interval="1" />
                </asp:ChartArea>
            </ChartAreas>
        </asp:Chart>
    </div>
</div>

<script type="text/javascript">

</script>