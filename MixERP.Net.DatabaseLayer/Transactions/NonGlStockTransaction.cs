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
    public static class NonGLStockTransaction
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        public static long Add(string book, DateTime valueDate, int officeId, int userId, long logOnId, string referenceNumber, string statementReference, MixERP.Net.Common.Models.Transactions.StockMasterModel stockMaster, Collection<MixERP.Net.Common.Models.Transactions.StockMasterDetailModel> details)
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
            long nonGlStockMasterId = 0;

            //decimal total = details.Sum(d => (d.Price * d.Quantity));
            //decimal discountTotal = details.Sum(d => d.Discount);
            //decimal taxTotal = details.Sum(d => d.Tax);

            using(NpgsqlConnection connection = new NpgsqlConnection(DBFactory.DBConnection.ConnectionString()))
            {
                connection.Open();

                using(NpgsqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {

                        #region NonGLStockMaster
                        sql = "INSERT INTO transactions.non_gl_stock_master(non_gl_stock_master_id, value_date, book, party_id, price_type_id, login_id, user_id, office_id, reference_number, statement_reference) SELECT nextval(pg_get_serial_sequence('transactions.non_gl_stock_master', 'non_gl_stock_master_id')), @ValueDate, @Book, core.get_party_id_by_party_code(@PartyCode), @PriceTypeId, @LoginId, @UserId, @OfficeId, @ReferenceNumber, @StatementReference; SELECT currval(pg_get_serial_sequence('transactions.non_gl_stock_master', 'non_gl_stock_master_id'));";

                        using(NpgsqlCommand stockMasterRow = new NpgsqlCommand(sql, connection))
                        {
                            stockMasterRow.Parameters.AddWithValue("@ValueDate", valueDate);
                            stockMasterRow.Parameters.AddWithValue("@Book", book);
                            stockMasterRow.Parameters.AddWithValue("@PartyCode", stockMaster.PartyCode);

                            if(stockMaster.PriceTypeId.Equals(0))
                            {
                                stockMasterRow.Parameters.AddWithValue("@PriceTypeId", DBNull.Value);
                            }
                            else
                            {
                                stockMasterRow.Parameters.AddWithValue("@PriceTypeId", stockMaster.PriceTypeId);
                            }

                            stockMasterRow.Parameters.AddWithValue("@LoginId", logOnId);
                            stockMasterRow.Parameters.AddWithValue("@UserId", userId);
                            stockMasterRow.Parameters.AddWithValue("@OfficeId", officeId);
                            stockMasterRow.Parameters.AddWithValue("@ReferenceNumber", referenceNumber);

                            stockMasterRow.Parameters.AddWithValue("@StatementReference", statementReference);

                            nonGlStockMasterId = MixERP.Net.Common.Conversion.TryCastLong(stockMasterRow.ExecuteScalar());
                        }

                        #region NonGLStockDetails
                        sql = @"INSERT INTO 
                                transactions.non_gl_stock_details(non_gl_stock_master_id, item_id, quantity, unit_id, base_quantity, base_unit_id, price, discount, tax_rate, tax) 
                                SELECT  @NonGlStockMasterId, core.get_item_id_by_item_code(@ItemCode), @Quantity, core.get_unit_id_by_unit_name(@UnitName), core.get_base_quantity_by_unit_name(@UnitName, @Quantity), core.get_base_unit_id_by_unit_name(@UnitName), @Price, @Discount, @TaxRate, @Tax;";

                        foreach(MixERP.Net.Common.Models.Transactions.StockMasterDetailModel model in details)
                        {
                            using(NpgsqlCommand stockMasterDetailRow = new NpgsqlCommand(sql, connection))
                            {
                                stockMasterDetailRow.Parameters.AddWithValue("@NonGlStockMasterId", nonGlStockMasterId);
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
                        return nonGlStockMasterId;
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

        public static System.Data.DataTable GetView(int officeId, string book)
        {
            string sql = @"WITH RECURSIVE office_cte(office_id) AS 
                        (
	                        SELECT @OfficeId
	                        UNION ALL
	                        SELECT
		                        c.office_id
	                        FROM 
                                office_cte AS p, 
                                office.offices AS c 
                            WHERE 
                                parent_office_id = p.office_id
                        )
                        SELECT
	                        transactions.non_gl_stock_master.non_gl_stock_master_id AS id,
	                        transactions.non_gl_stock_master.value_date,
	                        office.offices.office_code AS office,
	                        core.parties.party_code || ' (' || core.parties.party_name || ')' AS party,
	                        core.price_types.price_type_code || ' (' || core.price_types.price_type_name || ')' AS price_type,
	                        transactions.non_gl_stock_master.transaction_ts,
	                        office.users.user_name AS user,
	                        transactions.non_gl_stock_master.reference_number,
	                        transactions.non_gl_stock_master.statement_reference
                        FROM transactions.non_gl_stock_master
                        INNER JOIN core.parties
                        ON transactions.non_gl_stock_master.party_id = core.parties.party_id
                        INNER JOIN core.price_types
                        ON transactions.non_gl_stock_master.price_type_id = core.price_types.price_type_id
                        INNER JOIN office.users
                        ON transactions.non_gl_stock_master.user_id = office.users.user_id
                        INNER JOIN office.offices
                        ON transactions.non_gl_stock_master.office_id = office.offices.office_id
                        WHERE transactions.non_gl_stock_master.book = @Book
                        AND office.offices.office_id IN (SELECT office_id FROM office_cte);";

            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@OfficeId", officeId);
                command.Parameters.AddWithValue("@Book", book);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }
    }
}
