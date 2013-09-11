<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SalesByOfficeWidget.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.Widgets.SalesByOfficeWidget" %>
<div class="panel double-panel">
    <div class="panel-title">
        Sales By Office (Todo: Admin Only/Child Offices Only)
    </div>
    <div class="panel-content">
        <asp:Chart runat="server" ID="ctl00" Height="212px" Width="442px">
            <Series>
                <asp:Series Name="California" ChartType="Column">
                    <Points>
                        <asp:DataPoint AxisLabel="Jan" YValues="05" />
                        <asp:DataPoint AxisLabel="Feb" YValues="40" />
                        <asp:DataPoint AxisLabel="Mar" YValues="45" />
                        <asp:DataPoint AxisLabel="Apr" YValues="10" />
                        <asp:DataPoint AxisLabel="May" YValues="80" />
                        <asp:DataPoint AxisLabel="Jun" YValues="45" />
                        <asp:DataPoint AxisLabel="Jul" YValues="38" />
                        <asp:DataPoint AxisLabel="Aug" YValues="22" />
                        <asp:DataPoint AxisLabel="Sep" YValues="95" />
                        <asp:DataPoint AxisLabel="Oct" YValues="90" />
                        <asp:DataPoint AxisLabel="Nov" YValues="70" />
                        <asp:DataPoint AxisLabel="Dec" YValues="30" />
                    </Points>
                </asp:Series>
                <asp:Series Name="Brooklyn" ChartType="Column">
                    <Points>
                        <asp:DataPoint AxisLabel="Jan" YValues="50" />
                        <asp:DataPoint AxisLabel="Feb" YValues="30" />
                        <asp:DataPoint AxisLabel="Mar" YValues="12" />
                        <asp:DataPoint AxisLabel="Apr" YValues="18" />
                        <asp:DataPoint AxisLabel="May" YValues="70" />
                        <asp:DataPoint AxisLabel="Jun" YValues="38" />
                        <asp:DataPoint AxisLabel="Jul" YValues="48" />
                        <asp:DataPoint AxisLabel="Aug" YValues="69" />
                        <asp:DataPoint AxisLabel="Sep" YValues="42" />
                        <asp:DataPoint AxisLabel="Oct" YValues="22" />
                        <asp:DataPoint AxisLabel="Nov" YValues="38" />
                        <asp:DataPoint AxisLabel="Dec" YValues="60" />
                    </Points>
                </asp:Series>
                <asp:Series Name="Memphis" ChartType="Column">
                    <Points>
                        <asp:DataPoint AxisLabel="Jan" YValues="10" />
                        <asp:DataPoint AxisLabel="Feb" YValues="70" />
                        <asp:DataPoint AxisLabel="Mar" YValues="45" />
                        <asp:DataPoint AxisLabel="Apr" YValues="40" />
                        <asp:DataPoint AxisLabel="May" YValues="90" />
                        <asp:DataPoint AxisLabel="Jun" YValues="60" />
                        <asp:DataPoint AxisLabel="Jul" YValues="68" />
                        <asp:DataPoint AxisLabel="Aug" YValues="48" />
                        <asp:DataPoint AxisLabel="Sep" YValues="25" />
                        <asp:DataPoint AxisLabel="Oct" YValues="80" />
                        <asp:DataPoint AxisLabel="Nov" YValues="75" />
                        <asp:DataPoint AxisLabel="Dec" YValues="95" />
                    </Points>
                </asp:Series>
            </Series>
            <Legends>
                <asp:Legend Alignment="Center" Docking="Top" />
            </Legends>
            <ChartAreas>
                <asp:ChartArea Name="ChartArea1" Area3DStyle-IsClustered="true" Area3DStyle-Enable3D="true" Area3DStyle-LightStyle="Simplistic" BackColor="White" BackSecondaryColor="White" BorderColor="Gray">
                    <AxisX Interval="1"></AxisX>
                </asp:ChartArea>
            </ChartAreas>
        </asp:Chart>
    </div>
</div>
