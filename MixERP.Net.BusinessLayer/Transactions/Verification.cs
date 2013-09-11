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

namespace MixERP.Net.BusinessLayer.Transactions
{
    public static class Verification
    {
        public static MixERP.Net.Common.Models.Transactions.VerificationModel GetVerificationStatus(long transactionMasterId)
        {
            return MixERP.Net.DatabaseLayer.Transactions.Verification.GetVerificationStatus(transactionMasterId);
        }

        public static bool WithdrawTransaction(long transactionMasterId, int userId, string reason)
        {
            return MixERP.Net.DatabaseLayer.Transactions.Verification.WithdrawTransaction(transactionMasterId, userId, reason);
        }
    }
}
