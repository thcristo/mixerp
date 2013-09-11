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
    public class TransactionMasterModel
    {
        public long TransactionMasterId { get; set; }
        public int TransactionCounter { get; set; }
        public string TransactionCode { get; set; }
        public string Book { get; set; }
        public DateTime ValueDate { get; set; }
        public DateTime TransactionTimestamp { get; set; }
        public long LogOnId { get; set; }
        public int SysUserId { get; set; }
        public int OfficeId { get; set; }
        public int CostCenterId { get; set; }
        public string ReferenceNumber { get; set; }
        public string StatementReference { get; set; }
        public VerificationType Verification { get; set; }
    }
}
