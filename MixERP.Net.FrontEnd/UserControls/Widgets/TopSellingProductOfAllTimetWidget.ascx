<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TopSellingProductOfAllTimetWidget.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.Widgets.TopSellingProductOfAllTimetWidget" %>
<div class="panel double-panel">
    <div class="panel-title">
        Top 5 Selling Products of All Time(Todo: Same)
    </div>
    <div class="panel-content">
        <asp:Chart runat="server" ID="ctl02" Height="212px" Width="442px">
            <Series>
                <asp:Series Name="California" ChartType="Column">
                    <Points>
                        <asp:DataPoint AxisLabel="IBM Thinkpad II" YValues="05" />
                        <asp:DataPoint AxisLabel="MacBook Pro" YValues="40" />
                        <asp:DataPoint AxisLabel="Microsoft Office" YValues="45" />
                        <asp:DataPoint AxisLabel="Acer Iconia Tab" YValues="10" />
                        <asp:DataPoint AxisLabel="Samsung Galaxy Tab" YValues="80" />
                    </Points>
                </asp:Series>
                <asp:Series Name="Brooklyn" ChartType="Column">
                    <Points>
                        <asp:DataPoint AxisLabel="IBM Thinkpad II" YValues="15" />
                        <asp:DataPoint AxisLabel="MacBook Pro" YValues="30" />
                        <asp:DataPoint AxisLabel="Microsoft Office" YValues="55" />
                        <asp:DataPoint AxisLabel="Acer Iconia Tab" YValues="85" />
                        <asp:DataPoint AxisLabel="Samsung Galaxy Tab" YValues="20" />
                    </Points>
                </asp:Series>
                <asp:Series Name="Memphis" ChartType="Column">
                    <Points>
                        <asp:DataPoint AxisLabel="IBM Thinkpad II" YValues="10" />
                        <asp:DataPoint AxisLabel="MacBook Pro" YValues="80" />
                        <asp:DataPoint AxisLabel="Microsoft Office" YValues="65" />
                        <asp:DataPoint AxisLabel="Acer Iconia Tab" YValues="48" />
                        <asp:DataPoint AxisLabel="Samsung Galaxy Tab" YValues="65" />
                    </Points>
                </asp:Series>
            </Series>
            <Legends>
                <asp:Legend Alignment="Center" Docking="Top" />
            </Legends>
            <ChartAreas>
                <asp:ChartArea Name="ChartArea1" Area3DStyle-IsClustered="true" Area3DStyle-Enable3D="true" Area3DStyle-LightStyle="Simplistic" BackColor="White" BackSecondaryColor="White" BorderColor="Gray">
                </asp:ChartArea>
            </ChartAreas>
        </asp:Chart>
    </div>
</div>
