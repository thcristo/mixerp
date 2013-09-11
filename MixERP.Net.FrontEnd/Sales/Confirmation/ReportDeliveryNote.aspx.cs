/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MixERP.Net.FrontEnd.Sales.Confirmation
{
    public partial class ReportDeliveryNote : MixERP.Net.BusinessLayer.BasePageClass
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            System.Collections.ObjectModel.Collection<System.Collections.ObjectModel.Collection<KeyValuePair<string, string>>> parameters = new System.Collections.ObjectModel.Collection<System.Collections.ObjectModel.Collection<KeyValuePair<string, string>>>();

            System.Collections.ObjectModel.Collection<KeyValuePair<string, string>> list = new System.Collections.ObjectModel.Collection<KeyValuePair<string, string>>();
            list.Add(new KeyValuePair<string, string>("@transaction_master_id", this.Request["TranId"]));

            parameters.Add(list);
            parameters.Add(list);

            DeliveryNoteReport.ParameterCollection = parameters;
        }
    }
}