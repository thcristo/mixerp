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
using Npgsql;

namespace MixERP.Net.DatabaseLayer.Transactions
{
    public static class Transaction
    {
        public static long Add(DateTime valueDate, int officeId, int userId, long logOnId, int costCenterId, string referenceNumber, Collection<MixERP.Net.Common.Models.Transactions.TransactionDetailModel> details)
        {
            if(details == null)
            {
                return 0;
            }

            if(details.Count.Equals(0))
            {
                return 0;
            }

            string sql = string.Empty;
            long transactionMasterId = 0;

            decimal debitTotal = details.Sum(d => (d.Debit));
            decimal creditTotal = details.Sum(d => (d.Credit));
            string tranType = string.Empty;
            decimal amount = 0;


            if(debitTotal != creditTotal)
            {
                return 0;
            }


            using(NpgsqlConnection connection = new NpgsqlConnection(DBFactory.DBConnection.ConnectionString()))
            {
                connection.Open();

                using(NpgsqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {

                        sql = "INSERT INTO transactions.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, user_id, login_id, office_id, cost_center_id, reference_number) SELECT nextval(pg_get_serial_sequence('transactions.transaction_master', 'transaction_master_id')), transactions.get_new_transaction_counter(@ValueDate), transactions.get_transaction_code(@ValueDate, @OfficeId, @UserId, @LogOnId), @Book, @ValueDate, @UserId, @LogOnId, @OfficeId, @CostCenterId, @ReferenceNumber;SELECT currval(pg_get_serial_sequence('transactions.transaction_master', 'transaction_master_id'));";
                        using(NpgsqlCommand master = new NpgsqlCommand(sql, connection))
                        {
                            master.Parameters.AddWithValue("@ValueDate", valueDate);
                            master.Parameters.AddWithValue("@OfficeId", officeId);
                            master.Parameters.AddWithValue("@UserId", userId);
                            master.Parameters.AddWithValue("@LogOnId", logOnId);
                            master.Parameters.AddWithValue("@Book", "Journal");
                            master.Parameters.AddWithValue("@CostCenterId", costCenterId);
                            master.Parameters.AddWithValue("@ReferenceNumber", referenceNumber);

                            transactionMasterId = MixERP.Net.Common.Conversion.TryCastLong(master.ExecuteScalar());
                        }

                        foreach(MixERP.Net.Common.Models.Transactions.TransactionDetailModel model in details)
                        {
                            sql = "INSERT INTO transactions.transaction_details(transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, amount) SELECT @TransactionMasterId, @TranType, core.get_account_id_by_account_code(@AccountCode::text), @StatementReference, office.get_cash_repository_id_by_cash_repository_name(@CashRepositoryName::text), @Amount;";

                            if(model.Credit > 0 && model.Debit > 0)
                            {
                                throw new InvalidOperationException(MixERP.Net.Common.Helpers.LocalizationHelper.GetResourceString("Warnings", "BothSidesHaveValue"));
                            }
                            else
                            {
                                if(model.Credit.Equals(0) && model.Debit > 0)
                                {
                                    tranType = "Dr";
                                    amount = model.Debit;
                                }
                                else
                                {
                                    tranType = "Cr";
                                    amount = model.Credit;
                                }


                                using(NpgsqlCommand transactionDetail = new NpgsqlCommand(sql, connection))
                                {
                                    transactionDetail.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                                    transactionDetail.Parameters.AddWithValue("@TranType", tranType);
                                    transactionDetail.Parameters.AddWithValue("@AccountCode", model.AccountCode);
                                    transactionDetail.Parameters.AddWithValue("@StatementReference", model.StatementReference);
                                    transactionDetail.Parameters.AddWithValue("@CashRepositoryName", model.CashRepositoryName);
                                    transactionDetail.Parameters.AddWithValue("@Amount", amount);
                                    transactionDetail.ExecuteNonQuery();
                                }

                            }

                        }

                        transaction.Commit();
                        return transactionMasterId;
                    }
                    catch(NpgsqlException)
                    {
                        transaction.Rollback();
                        throw;
                    }
                    catch(InvalidOperationException)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
        }

    }
}
