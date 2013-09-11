<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="OfficeInformationWidget.ascx.cs" Inherits="MixERP.Net.FrontEnd.UserControls.Widgets.OfficeInformationWidget" %>
<div class="panel">
    <div class="panel-title">
        Office Information (Todo)
    </div>
    <div class="panel-content">
        Your Office : PES-NY-MEM (Memphis Branch)
                    <br />
        Logged in to : PES-NY-BK (Brooklyn Branch)
                    <br />
        Last Login IP : 192.168.0.200
                <br />
        Last Login On : <%=System.DateTime.Now.ToString() %>
        <br />
        Current Login IP : 192.168.0.200
                <br />
        Current Login On: <%=System.DateTime.Now.ToString() %>
        <br />
        Role : ADM (Administrators)
                    <br />
        Department : ITD (IT Department)
    </div>
</div>
