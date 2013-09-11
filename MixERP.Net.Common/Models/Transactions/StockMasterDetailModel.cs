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
    public class StockMasterDetailModel
    {
        public long StockMasterDetailId { get; set; }
        public long StockMasterId { get; set; }
        public TransactionType TransactionType { get; set; }
        public int StoreId { get; set; }
        public string ItemCode { get; set; }
        public int Quantity { get; set; }
        public string UnitName { get; set; }
        public decimal Price { get; set; }
        public decimal Discount { get; set; }
        public decimal TaxRate { get; set; }
        public decimal Tax { get; set; }
    }
}
