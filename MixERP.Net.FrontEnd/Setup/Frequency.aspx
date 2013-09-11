<%-- 
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
--%>
<%@ Page Title="" Language="C#" MasterPageFile="~/ContentMaster.Master" AutoEventWireup="true" CodeBehind="Frequency.aspx.cs" Inherits="MixERP.Net.FrontEnd.Setup.Frequency" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ScriptContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="StyleSheetContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <mixerp:Form ID="FrequencySetupForm" runat="server" DenyAdd="false" DenyDelete="false" DenyEdit="false" KeyColumn="frequency_setup_id"
        PageSize="10" TableSchema="core" Table="frequency_setups" ViewSchema="core" View="frequency_setups" 
        Text="<%$Resources:Titles, Frequencies %>" Width="1000"
        DisplayFields="core.frequencies.frequency_id-->frequency_name, core.fiscal_year.fiscal_year_code-->fiscal_year_code + ' (' + fiscal_year_name + ')'" 
        DisplayViews="core.frequencies.frequency_id-->core.frequencies, core.fiscal_year.fiscal_year_code-->core.fiscal_year" 
        
        />
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="BottomScriptContentPlaceHolder" runat="server">
</asp:Content>
