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
        <table id="curr-office-top-selling-products-datasource">
            <thead>
                <tr>
                    <th></th>
                    <th>California</th>
                    <th>Brooklyn</th>
                    <th>Memphis</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <th>IBM Thinkpad II</th>
                    <td>15</td>
                    <td>55</td>
                    <td>20</td>
                </tr>
                <tr>
                    <th>MacBook Pro</th>
                    <td>40</td>
                    <td>30</td>
                    <td>80</td>
                </tr>
                <tr>
                    <th>Microsoft Office</th>
                    <td>45</td>
                    <td>55</td>
                    <td>65</td>
                </tr>
                <tr>
                    <th>Acer Iconia Tab</th>
                    <td>20</td>
                    <td>85</td>
                    <td>48</td>
                </tr>
                <tr>
                    <th>Samsung Galaxy Tab</th>
                    <td>80</td>
                    <td>20</td>
                    <td>65</td>
                </tr>
            </tbody>
        </table>

        <canvas id="curr-office-top-selling-products-canvas" width="500px" height="180px"></canvas>
        <div id="curr-office-top-selling-products-legend"></div>



    </div>
</div>

<script type="text/javascript">
    prepareChart("curr-office-top-selling-products-datasource", "curr-office-top-selling-products-canvas", "curr-office-top-selling-products-legend", 'bar');
</script>
