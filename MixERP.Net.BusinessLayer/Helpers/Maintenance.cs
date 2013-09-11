/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Text;

namespace MixERP.Net.BusinessLayer.Helpers
{
    public static class Maintenance
    {
        public static void Vacuum()
        {
            MixERP.Net.DatabaseLayer.Helpers.Maintenance.Vacuum();
        }

        public static void VacuumFull()
        {
            MixERP.Net.DatabaseLayer.Helpers.Maintenance.VacuumFull();
        }

        public static void Analyze()
        {
            MixERP.Net.DatabaseLayer.Helpers.Maintenance.Analyze();
        }
    }
}
