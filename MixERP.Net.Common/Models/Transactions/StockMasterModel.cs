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
    public class StockMasterModel
    {
        public long StockMasterId { get; set; }
        public long TransactionMasterId { get; set; }
        public string PartyCode { get; set; }
        public int AgentId { get; set; }
        public int PriceTypeId { get; set; }
        public bool IsCredit { get; set; }
        public int ShipperId { get; set; }
        public string ShippingAddressCode { get; set; }
        public decimal ShippingCharge { get; set; }
        public int StoreId { get; set; }
        public int CashRepositoryId { get; set; }
    }
}
