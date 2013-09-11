/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Npgsql;

namespace MixERP.Net.DatabaseLayer.Transactions
{
    public static class Verification
    {
        public static MixERP.Net.Common.Models.Transactions.VerificationModel GetVerificationStatus(long transactionMasterId)
        {
            MixERP.Net.Common.Models.Transactions.VerificationModel model = new MixERP.Net.Common.Models.Transactions.VerificationModel();
            string sql = "SELECT verification_status_id, office.get_user_name_by_user_id(verified_by_user_id) AS verified_by_user_name, verified_by_user_id, last_verified_on, verification_reason FROM transactions.transaction_master WHERE transaction_master_id=@TransactionMasterId;";

            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);

                using(DataTable table = MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command))
                {
                    if(table != null)
                    {
                        if(table.Rows.Count.Equals(1))
                        {
                            DataRow row = table.Rows[0];

                            model.Verification = MixERP.Net.Common.Conversion.TryCastShort(row["verification_status_id"]);
                            model.VerifierUserId = MixERP.Net.Common.Conversion.TryCastInteger(row["verified_by_user_id"]);
                            model.VerifierName = MixERP.Net.Common.Conversion.TryCastString(row["verified_by_user_name"]);
                            model.VerifiedDate = MixERP.Net.Common.Conversion.TryCastDate(row["last_verified_on"]);
                            model.VerificationReason = MixERP.Net.Common.Conversion.TryCastString(row["verification_reason"]);
                        }
                    }
                }
            }
            
            
            return model;
        }

        public static bool WithdrawTransaction(long transactionMasterId, int userId, string reason)
        {
            short status = MixERP.Net.Common.Models.Transactions.VerificationDomain.GetVerification(MixERP.Net.Common.Models.Transactions.VerificationType.Withdrawn);

            string sql = "UPDATE transactions.transaction_master SET verification_status_id=@Status, verified_by_user_id=@UserId, verification_reason=@Reason WHERE transactions.transaction_master.transaction_master_id=@TransactionMasterId;";
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@Status", status);
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@reason", reason);
                command.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.ExecuteNonQuery(command);
            }
        }

        public static bool CallAutoVerification(long transactionMasterId)
        {
            if(MixERP.Net.Common.Helpers.Switches.EnableAutoVerification())
            {
                string sql = "SELECT transactions.auto_verify(@TransactionMasterId::bigint);";
                using(NpgsqlCommand command = new NpgsqlCommand(sql))
                {
                    command.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                    return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.ExecuteNonQuery(command);
                }
            }

            return false;
        }
    }
}
