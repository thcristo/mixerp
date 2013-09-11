/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.Linq;
using System.Text;
using Npgsql;

namespace MixERP.Net.DatabaseLayer.Transactions
{
    public static class DirectPurchase
    {

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        public static long Add(DateTime valueDate, int officeId, int userId, long logOnId, int costCenterId, string referenceNumber, string statementReference, MixERP.Net.Common.Models.Transactions.StockMasterModel stockMaster, Collection<MixERP.Net.Common.Models.Transactions.StockMasterDetailModel> details)
        {
            if(stockMaster == null)
            {
                return 0;
            }

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
            long stockMasterId = 0;

            decimal total = details.Sum(d => (d.Price * d.Quantity));
            decimal discountTotal = details.Sum(d => d.Discount);
            decimal taxTotal = details.Sum(d => d.Tax);

            string creditInvariantParameter = "Purchase.Payables";
            string purchaseInvariantParameter = "Purchase";
            string purchaseTaxInvariantParamter = "Purchase.Tax";
            string purchaseDiscountInvariantParameter = "Purchase.Discount";


            using(NpgsqlConnection connection = new NpgsqlConnection(DBFactory.DBConnection.ConnectionString()))
            {
                connection.Open();

                using(NpgsqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {

                        #region TransactionMaster
                        sql = "INSERT INTO transactions.transaction_master(transaction_master_id, transaction_counter, transaction_code, book, value_date, user_id, login_id, office_id, cost_center_id, reference_number, statement_reference) SELECT nextval(pg_get_serial_sequence('transactions.transaction_master', 'transaction_master_id')), transactions.get_new_transaction_counter(@ValueDate), transactions.get_transaction_code(@ValueDate, @OfficeId, @UserId, @LogOnId), @Book, @ValueDate, @UserId, @LogOnId, @OfficeId, @CostCenterId, @ReferenceNumber, @StatementReference;SELECT currval(pg_get_serial_sequence('transactions.transaction_master', 'transaction_master_id'));";
                        using(NpgsqlCommand tm = new NpgsqlCommand(sql, connection))
                        {
                            tm.Parameters.AddWithValue("@ValueDate", valueDate);
                            tm.Parameters.AddWithValue("@OfficeId", officeId);
                            tm.Parameters.AddWithValue("@UserId", userId);
                            tm.Parameters.AddWithValue("@LogOnId", logOnId);
                            tm.Parameters.AddWithValue("@Book", "Purchase.Direct");
                            tm.Parameters.AddWithValue("@CostCenterId", costCenterId);
                            tm.Parameters.AddWithValue("@ReferenceNumber", referenceNumber);
                            tm.Parameters.AddWithValue("@StatementReference", statementReference);

                            transactionMasterId = MixERP.Net.Common.Conversion.TryCastLong(tm.ExecuteScalar());
                        }

                        #region TransactionDetails
                        sql = "INSERT INTO transactions.transaction_details(transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, amount) SELECT @TransactionMasterId, @TranType, core.get_account_id_by_parameter(@ParameterName), @StatementReference, @CashRepositoryId, @Amount;";

                        using(NpgsqlCommand purchaseRow = new NpgsqlCommand(sql, connection))
                        {
                            purchaseRow.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                            purchaseRow.Parameters.AddWithValue("@TranType", "Dr");
                            purchaseRow.Parameters.AddWithValue("@ParameterName", purchaseInvariantParameter);
                            purchaseRow.Parameters.AddWithValue("@StatementReference", statementReference);
                            purchaseRow.Parameters.AddWithValue("@CashRepositoryId", DBNull.Value);
                            purchaseRow.Parameters.AddWithValue("@Amount", total);

                            purchaseRow.ExecuteNonQuery();
                        }

                        if(taxTotal > 0)
                        {
                            using(NpgsqlCommand taxRow = new NpgsqlCommand(sql, connection))
                            {
                                taxRow.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                                taxRow.Parameters.AddWithValue("@TranType", "Dr");
                                taxRow.Parameters.AddWithValue("@ParameterName", purchaseTaxInvariantParamter);
                                taxRow.Parameters.AddWithValue("@StatementReference", statementReference);
                                taxRow.Parameters.AddWithValue("@CashRepositoryId", DBNull.Value);
                                taxRow.Parameters.AddWithValue("@Amount", taxTotal);
                                taxRow.ExecuteNonQuery();
                            }
                        }

                        if(discountTotal > 0)
                        {
                            using(NpgsqlCommand discountRow = new NpgsqlCommand(sql, connection))
                            {
                                discountRow.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                                discountRow.Parameters.AddWithValue("@TranType", "Cr");
                                discountRow.Parameters.AddWithValue("@ParameterName", purchaseDiscountInvariantParameter);
                                discountRow.Parameters.AddWithValue("@StatementReference", statementReference);
                                discountRow.Parameters.AddWithValue("@CashRepositoryId", DBNull.Value);
                                discountRow.Parameters.AddWithValue("@Amount", discountTotal);
                                discountRow.ExecuteNonQuery();
                            }
                        }

                        if(stockMaster.IsCredit)
                        {
                            using(NpgsqlCommand creditRow = new NpgsqlCommand(sql, connection))
                            {
                                creditRow.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                                creditRow.Parameters.AddWithValue("@TranType", "Cr");
                                creditRow.Parameters.AddWithValue("@ParameterName", creditInvariantParameter);
                                creditRow.Parameters.AddWithValue("@StatementReference", statementReference);
                                creditRow.Parameters.AddWithValue("@CashRepositoryId", DBNull.Value);
                                creditRow.Parameters.AddWithValue("@Amount", total - discountTotal + taxTotal);
                                creditRow.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            sql = "INSERT INTO transactions.transaction_details(transaction_master_id, tran_type, account_id, statement_reference, cash_repository_id, amount) SELECT @TransactionMasterId, @TranType, core.get_cash_account_id(), @StatementReference, @CashRepositoryId, @Amount;";

                            using(NpgsqlCommand cashRow = new NpgsqlCommand(sql, connection))
                            {
                                cashRow.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                                cashRow.Parameters.AddWithValue("@TranType", "Cr");
                                cashRow.Parameters.AddWithValue("@StatementReference", statementReference);
                                cashRow.Parameters.AddWithValue("@CashRepositoryId", stockMaster.CashRepositoryId);
                                cashRow.Parameters.AddWithValue("@Amount", total - discountTotal + taxTotal);
                                cashRow.ExecuteNonQuery();
                            }
                        }
                        #endregion
                        #endregion

                        #region StockMaster

                        sql = "INSERT INTO transactions.stock_master(stock_master_id, transaction_master_id, party_id, is_credit, shipper_id, shipping_charge, store_id, cash_repository_id) SELECT nextval(pg_get_serial_sequence('transactions.stock_master', 'stock_master_id')), @TransactionMasterId, core.get_party_id_by_party_code(@PartyCode), @IsCredit, @ShipperId, @ShippingCharge, @StoreId, @CashRepositoryId; SELECT currval(pg_get_serial_sequence('transactions.stock_master', 'stock_master_id'));";

                        using(NpgsqlCommand stockMasterRow = new NpgsqlCommand(sql, connection))
                        {
                            stockMasterRow.Parameters.AddWithValue("@TransactionMasterId", transactionMasterId);
                            stockMasterRow.Parameters.AddWithValue("@PartyCode", stockMaster.PartyCode);
                            stockMasterRow.Parameters.AddWithValue("@IsCredit", stockMaster.IsCredit);

                            if(stockMaster.ShipperId.Equals(0))
                            {
                                stockMasterRow.Parameters.AddWithValue("@ShipperId", DBNull.Value);
                            }
                            else
                            {
                                stockMasterRow.Parameters.AddWithValue("@ShipperId", stockMaster.ShipperId);
                            }

                            stockMasterRow.Parameters.AddWithValue("@ShippingCharge", stockMaster.ShippingCharge);

                            stockMasterRow.Parameters.AddWithValue("@StoreId", stockMaster.StoreId);
                            stockMasterRow.Parameters.AddWithValue("@CashRepositoryId", stockMaster.CashRepositoryId);

                            stockMasterId = MixERP.Net.Common.Conversion.TryCastLong(stockMasterRow.ExecuteScalar());
                        }

                        #region StockDetails
                        sql = @"INSERT INTO 
                                transactions.stock_details(stock_master_id, tran_type, store_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, discount, tax_rate, tax) 
                                SELECT  @StockMasterId, @TranType, @StoreId, core.get_item_id_by_item_code(@ItemCode), @Quantity, core.get_unit_id_by_unit_name(@UnitName), core.get_base_quantity_by_unit_name(@UnitName, @Quantity), core.get_base_unit_id_by_unit_name(@UnitName), @Price, @Discount, @TaxRate, @Tax;";

                        foreach(MixERP.Net.Common.Models.Transactions.StockMasterDetailModel model in details)
                        {
                            using(NpgsqlCommand stockMasterDetailRow = new NpgsqlCommand(sql, connection))
                            {
                                stockMasterDetailRow.Parameters.AddWithValue("@StockMasterId", stockMasterId);
                                stockMasterDetailRow.Parameters.AddWithValue("@TranType", "Dr");
                                stockMasterDetailRow.Parameters.AddWithValue("@StoreId", model.StoreId);
                                stockMasterDetailRow.Parameters.AddWithValue("@ItemCode", model.ItemCode);
                                stockMasterDetailRow.Parameters.AddWithValue("@Quantity", model.Quantity);
                                stockMasterDetailRow.Parameters.AddWithValue("@UnitName", model.UnitName);
                                stockMasterDetailRow.Parameters.AddWithValue("@Price", model.Price);
                                stockMasterDetailRow.Parameters.AddWithValue("@Discount", model.Discount);
                                stockMasterDetailRow.Parameters.AddWithValue("@TaxRate", model.TaxRate);
                                stockMasterDetailRow.Parameters.AddWithValue("@Tax", model.Tax);

                                stockMasterDetailRow.ExecuteNonQuery();
                            }
                        }

                        #endregion

                        #endregion

                        transaction.Commit();
                        return transactionMasterId;
                    }
                    catch(NpgsqlException)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }

                return 0;
            }
        }

    }
}
