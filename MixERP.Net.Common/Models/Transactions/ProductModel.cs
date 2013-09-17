/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;

namespace MixERP.Net.Common.Models.Transactions
{
    public class ProductModel
    {
        public DateTime ValueDate { get; set; }
        public int PartyId { get; set; }
        public int PriceTypeId { get; set; }
        public string ReferenceNumber { get; set; }
        public int AgentId { get; set; }
        public Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> View { get; set; }
        public string StatementReference { get; set; }
    }
}
