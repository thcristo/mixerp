/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MixERP.Net.Common.Models.Transactions
{
    public class TransactionDetailModel
    {
        public long TransactionDetailId { get; set; }
        public long TransactionMasterId { get; set; }
        public string AccountCode { get; set; }
        public string CashRepositoryName { get; set; }
        public string StatementReference { get; set; }
        public decimal Debit { get; set; }
        public decimal Credit { get; set; }
    }
}
