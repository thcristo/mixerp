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
            }
        }

        public static System.Data.DataTable GetView(int userId, string book, int officeId, DateTime dateFrom, DateTime dateTo, string office, string party, string priceType, string user, string referenceNumber, string statementReference)
        {
            string sql = "SELECT * FROM transactions.get_product_view(@UserId::integer, @Book::text, @OfficeId::integer, @DateFrom::date, @DateTo::date, @Office::national character varying(12), @Party::text, @PriceType::text, @User::national character varying(50), @ReferenceNumber::national character varying(24), @StatementReference::text);";

            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                command.Parameters.AddWithValue("@UserId", userId);
                command.Parameters.AddWithValue("@Book", book);
                command.Parameters.AddWithValue("@OfficeId", officeId);
                command.Parameters.AddWithValue("@DateFrom", dateFrom);
                command.Parameters.AddWithValue("@DateTo", dateTo);
                command.Parameters.AddWithValue("@Office", office);
                command.Parameters.AddWithValue("@Party", party);
                command.Parameters.AddWithValue("@PriceType", priceType);
                command.Parameters.AddWithValue("@User", user);
                command.Parameters.AddWithValue("@ReferenceNumber", referenceNumber);
                command.Parameters.AddWithValue("@StatementReference", statementReference);

                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

        public static bool TransactionIdsBelongToSameParty(Collection<int> ids)
        {
            //Crate an array object to store the parameters.
            var parameters = new string[ids.Count];

            //Iterate through the ids and create a parameter array.
            for(int i = 0; i < ids.Count; i++)
            {
                parameters[i] = "@Id" + MixERP.Net.Common.Conversion.TryCastString(i);
            }

            //Get the count of distinct number of parties associated with the transaction id.
            string sql = "SELECT COUNT(DISTINCT party_id) FROM transactions.non_gl_stock_master WHERE non_gl_stock_master_id IN(" + string.Join(",", parameters) + ");";

            //Create a PostgreSQL command object from the SQL string.
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                //Iterate through the IDs and add PostgreSQL parameters.
                for(int i = 0; i < ids.Count; i++)
                {
                    command.Parameters.AddWithValue("@Id" + MixERP.Net.Common.Conversion.TryCastString(i), ids[i]);
                }

                //If the transactions associated with the supplied transaction ids belong to a single part,
                //the value should equal to 1.
                return MixERP.Net.Common.Conversion.TryCastInteger(MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetScalarValue(command)).Equals(1);
            }
        }

        public static DataTable GetSalesQuotationView(Collection<int> ids)
        {
            //Crate an array object to store the parameters.
            var parameters = new string[ids.Count];

            //Iterate through the ids and create a parameter array.
            for(int i = 0; i < ids.Count; i++)
            {
                parameters[i] = "@Id" + MixERP.Net.Common.Conversion.TryCastString(i);
            }

            string sql = @"SELECT
	                        transactions.non_gl_stock_master.value_date,
	                        transactions.non_gl_stock_master.party_id,
	                        core.parties.party_code,
	                        transactions.non_gl_stock_master.price_type_id,
	                        transactions.non_gl_stock_master.reference_number,
	                        core.items.item_code,
	                        core.items.item_name,
	                        transactions.non_gl_stock_details.quantity,
	                        core.units.unit_name,
	                        transactions.non_gl_stock_details.price,
	                        transactions.non_gl_stock_details.discount,
	                        transactions.non_gl_stock_details.tax_rate,
	                        transactions.non_gl_stock_details.tax,	
	                        transactions.non_gl_stock_master.statement_reference
                        FROM
                        transactions.non_gl_stock_master
                        INNER JOIN
                        transactions.non_gl_stock_details
                        ON transactions.non_gl_stock_master.non_gl_stock_master_id = transactions.non_gl_stock_details.non_gl_stock_master_id
                        INNER JOIN core.items
                        ON transactions.non_gl_stock_details.item_id = core.items.item_id
                        INNER JOIN core.units
                        ON transactions.non_gl_stock_details.unit_id = core.units.unit_id
                        INNER JOIN core.parties
                        ON transactions.non_gl_stock_master.party_id = core.parties.party_id
                        WHERE transactions.non_gl_stock_master.non_gl_stock_master_id IN(" + string.Join(",", parameters) + ");";

            //Create a PostgreSQL command object from the SQL string.
            using(NpgsqlCommand command = new NpgsqlCommand(sql))
            {
                //Iterate through the IDs and add PostgreSQL parameters.
                for(int i = 0; i < ids.Count; i++)
                {
                    command.Parameters.AddWithValue("@Id" + MixERP.Net.Common.Conversion.TryCastString(i), ids[i]);
                }

                //If the transactions associated with the supplied transaction ids belong to a single part,
                //the value should equal to 1.
                return MixERP.Net.DatabaseLayer.DBFactory.DBOperations.GetDataTable(command);
            }
        }

    }
}
