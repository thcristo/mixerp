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
    public static class VerificationDomain
    {
        public static short GetVerification(VerificationType type)
        {
            switch(type)
            {
                case VerificationType.Rejected:
                    return -3;
                case VerificationType.Closed:
                    return -2;
                case VerificationType.Withdrawn:
                    return -1;
                case VerificationType.Unapproved:
                    return 0;
                case VerificationType.Approved:
                    return 1;
            }

            return 0;
        }
    }
}
