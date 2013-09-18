/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.ObjectModel;

namespace MixERP.Net.Common.Models.Transactions
{
    public class MergeModel
    {
        public DateTime ValueDate { get; set; }
        public string PartyCode { get; set; }
        public int PriceTypeId { get; set; }
        public string ReferenceNumber { get; set; }
        public int AgentId { get; set; }
        public Collection<MixERP.Net.Common.Models.Transactions.ProductDetailsModel> View { get; set; }
        public string StatementReference { get; set; }

        public MixERP.Net.Common.Models.Transactions.TranBook Book { get; set; }
        public MixERP.Net.Common.Models.Transactions.SubTranBook SubBook { get; set; }
        public Collection<int> transactionIdCollection { get; set; }
    }
}
