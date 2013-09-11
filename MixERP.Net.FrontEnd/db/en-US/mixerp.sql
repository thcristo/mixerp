/********************************************************************************
Copyright (C) Binod Nepal, Mix Open Foundation (http://mixof.org).

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
If a copy of the MPL was not distributed  with this file, You can obtain one at 
http://mozilla.org/MPL/2.0/.
***********************************************************************************/

/********************************************************************************
	NOTE: ALL RANDOM INDEXES ARE REMOVED FROM THE SCRIPT.
	TODO LIST : NEED TO CREATE INDEXES.
***********************************************************************************/

DROP SCHEMA IF EXISTS audit CASCADE;
DROP SCHEMA IF EXISTS core CASCADE;
DROP SCHEMA IF EXISTS office CASCADE;
DROP SCHEMA IF EXISTS policy CASCADE;
DROP SCHEMA IF EXISTS transactions CASCADE;
DROP SCHEMA IF EXISTS crm CASCADE;
DROP SCHEMA IF EXISTS mrp CASCADE;

CREATE SCHEMA audit;
CREATE SCHEMA core;
CREATE SCHEMA office;
CREATE SCHEMA policy;
CREATE SCHEMA transactions;
CREATE SCHEMA crm;
CREATE SCHEMA mrp;


CREATE TABLE core.verification_statuses
(
	verification_status_id			smallint NOT NULL PRIMARY KEY,
	verification_status_name		national character varying(128) NOT NULL
);

CREATE UNIQUE INDEX verification_statuses_verification_status_name_uix
ON core.verification_statuses(UPPER(verification_status_name));


--These are hardcoded values and therefore the meanings should always remain intact
--regardless of the language.
INSERT INTO core.verification_statuses
SELECT -3, 'Rejected' UNION ALL
SELECT -2, 'Closed' UNION ALL
SELECT -1, 'Withdrawn' UNION ALL
SELECT 0, 'Unverified' UNION ALL
SELECT 1, 'Automatically Approved by Workflow' UNION ALL
SELECT 2, 'Approved';

DROP DOMAIN IF EXISTS transaction_type;
CREATE DOMAIN transaction_type
AS char(2)
CHECK
(
	VALUE IN
	(
		'Dr', --Debit
		'Cr' --Credit
	)
);

/*******************************************************************
	MIXERP STRICT Data Types: NEGATIVES ARE NOT ALLOWED
*******************************************************************/

DROP DOMAIN IF EXISTS money_strict;
CREATE DOMAIN money_strict
AS money
CHECK
(
	VALUE > '0'
);


DROP DOMAIN IF EXISTS money_strict2;
CREATE DOMAIN money_strict2
AS money
CHECK
(
	VALUE >= '0'
);

DROP DOMAIN IF EXISTS integer_strict;
CREATE DOMAIN integer_strict
AS integer
CHECK
(
	VALUE > 0
);

DROP DOMAIN IF EXISTS integer_strict2;
CREATE DOMAIN integer_strict2
AS integer
CHECK
(
	VALUE >= 0
);

DROP DOMAIN IF EXISTS smallint_strict;
CREATE DOMAIN smallint_strict
AS smallint
CHECK
(
	VALUE > 0
);

DROP DOMAIN IF EXISTS smallint_strict2;
CREATE DOMAIN smallint_strict2
AS smallint
CHECK
(
	VALUE >= 0
);

DROP DOMAIN IF EXISTS decimal_strict;
CREATE DOMAIN decimal_strict
AS decimal
CHECK
(
	VALUE > 0
);

DROP VIEW IF EXISTS db_stat;
CREATE VIEW db_stat
AS
select
	relname,
	last_vacuum,
	last_autovacuum,
	last_analyze,
	last_autoanalyze,
	vacuum_count,
	autovacuum_count,
	analyze_count,
	autoanalyze_count
from
   pg_stat_user_tables;

DROP DOMAIN IF EXISTS decimal_strict2;
CREATE DOMAIN decimal_strict2
AS decimal
CHECK
(
	VALUE >= 0
);

DROP DOMAIN IF EXISTS image_path;
CREATE DOMAIN image_path
AS text;



CREATE TABLE office.users
(
	user_id 				SERIAL NOT NULL PRIMARY KEY,
	role_id 				smallint NOT NULL,
	office_id 				integer NOT NULL,
	user_name 				national character varying(50) NOT NULL,
	full_name 				national character varying(100) NOT NULL,
	password 				text NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE TABLE core.currencies
(
	currency_code				national character varying(12) NOT NULL PRIMARY KEY,
	currency_symbol				national character varying(12) NOT NULL,
	currency_name				national character varying(48) NOT NULL UNIQUE,
	hundredth_name				national character varying(48) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

INSERT INTO core.currencies
SELECT 'NPR', 'Rs.', 'Nepali Rupees', 'paisa' UNION ALL
SELECT 'USD', '$ ', 'United States Dollar', 'cents';

CREATE FUNCTION office.is_parent_office(child integer_strict, parent integer_strict)
RETURNS boolean
AS
$$		
BEGIN
	IF $1!=$2 THEN
		IF EXISTS
		(
			WITH RECURSIVE office_cte(office_id, path) AS (
			 SELECT
				tn.office_id,  tn.office_id::TEXT AS path
				FROM office.offices AS tn WHERE tn.parent_office_id IS NULL
			UNION ALL
			 SELECT
				c.office_id, (p.path || '->' || c.office_id::TEXT)
				FROM office_cte AS p, office.offices AS c WHERE parent_office_id = p.office_id
			)
			SELECT * FROM
			(
				SELECT regexp_split_to_table(path, '->')
				FROM office_cte AS n WHERE n.office_id = $2
			) AS items
			WHERE regexp_split_to_table=$1::text
		) THEN
			RETURN TRUE;
		END IF;
	END IF;
	RETURN false;
END
$$
LANGUAGE plpgsql;

CREATE TABLE office.offices
(
	office_id				SERIAL NOT NULL PRIMARY KEY,
	office_code 				national character varying(12) NOT NULL,
	office_name 				national character varying(150) NOT NULL,
	nick_name 				national character varying(50) NULL,
	registration_date 			date NOT NULL,
	currency_code 				national character varying(12) NOT NULL 
						CONSTRAINT offices_currencies_fk REFERENCES core.currencies(currency_code)
						CONSTRAINT offices_currency_code_df DEFAULT('NPR'),
	address_line_1				national character varying(128) NULL,	
	address_line_2				national character varying(128) NULL,
	street 					national character varying(50) NULL,
	city 					national character varying(50) NULL,
	state 					national character varying(50) NULL,
	country 				national character varying(50) NULL,
	zip_code 				national character varying(24) NULL,
	phone 					national character varying(24) NULL,
	fax 					national character varying(24) NULL,
	email 					national character varying(128) NULL,
	url 					national character varying(50) NULL,
	registration_number 			national character varying(24) NULL,
	pan_number 				national character varying(24) NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
	parent_office_id 			integer NULL REFERENCES office.offices(office_id)
		CHECK
		(
			office.is_parent_office(office_id, parent_office_id) = FALSE
			AND
			parent_office_id != office_id
		)
);

ALTER TABLE office.users
ADD FOREIGN KEY(office_id) REFERENCES office.offices(office_id);

CREATE UNIQUE INDEX offices_office_code_uix
ON office.offices(UPPER(office_code));

CREATE UNIQUE INDEX offices_office_name_uix
ON office.offices(UPPER(office_name));

CREATE UNIQUE INDEX offices_nick_name_uix
ON office.offices(UPPER(nick_name));


/*******************************************************************
	SAMPLE DATA FEED
	TODO: REMOVE THE BELOW BEFORE RELEASE
*******************************************************************/

INSERT INTO office.offices(office_code,office_name,nick_name,registration_date, street,city,state,country,zip_code,phone,fax,email,url,registration_number,pan_number)
SELECT 'PES','Planet Earth Solutions', 'PES Technologies', '06/06/1989', 'Brooklyn','NY','','US','','','','info@planetearthsolution.com','http://planetearthsolution.com','0','0';


INSERT INTO office.offices(office_code,office_name,nick_name, registration_date, street,city,state,country,zip_code,phone,fax,email,url,registration_number,pan_number,parent_office_id)
SELECT 'PES-NY-BK','Brooklyn Branch', 'PES Brooklyn', '06/06/1989', 'Brooklyn','NY','12345555','','','','','info@planetearthsolution.com','http://planetearthsolution.com','0','0',(SELECT office_id FROM office.offices WHERE office_code='PES');

INSERT INTO office.offices(office_code,office_name,nick_name, registration_date, street,city,state,country,zip_code,phone,fax,email,url,registration_number,pan_number,parent_office_id)
SELECT 'PES-NY-MEM','Memphis Branch', 'PES Memphis', '06/06/1989', 'Memphis', 'NY','','','','64464554','','info@planetearthsolution.com','http://planetearthsolution.com','0','0',(SELECT office_id FROM office.offices WHERE office_code='PES');


/*******************************************************************
	RETURNS MINI OFFICE TABLE
*******************************************************************/

CREATE TYPE office.office_type AS
(
	office_id				integer_strict,
	office_code 				national character varying(12),
	office_name 				national character varying(150),
	address text
);

CREATE FUNCTION office.get_offices()
RETURNS setof office.office_type
AS
$$
DECLARE "@record" office.office_type%rowtype;
BEGIN
	FOR "@record" IN SELECT office_id, office_code,office_name,street || ' ' || city AS Address FROM office.offices WHERE parent_office_id IS NOT NULL
	LOOP
		RETURN NEXT "@record";
	END LOOP;

	IF NOT FOUND THEN
		FOR "@record" IN SELECT office_id, office_code,office_name,street || ' ' || city AS Address FROM office.offices WHERE parent_office_id IS NULL
		LOOP
			RETURN NEXT "@record";
		END LOOP;
	END IF;

	RETURN;
END
$$
LANGUAGE plpgsql;


CREATE FUNCTION office.get_office_name_by_id(office_id integer_strict)
RETURNS text
AS
$$
BEGIN
	RETURN
	(
		SELECT office.offices.office_name FROM office.offices
		WHERE office.offices.office_id=$1
	);
END
$$
LANGUAGE plpgsql;


--TODO
CREATE VIEW office.office_view
AS
SELECT * FROM office.offices;

CREATE TABLE office.departments
(
	department_id SERIAL			NOT NULL PRIMARY KEY,
	department_code				national character varying(12) NOT NULL,
	department_name				national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX departments_department_code_uix
ON office.departments(UPPER(department_code));

CREATE UNIQUE INDEX departments_department_name_uix
ON office.departments(UPPER(department_name));


INSERT INTO office.departments(department_code, department_name)
SELECT 'SAL', 'Sales & Billing' UNION ALL
SELECT 'MKT', 'Marketing & Promotion' UNION ALL
SELECT 'SUP', 'Support' UNION ALL
SELECT 'CC', 'Customer Care';


CREATE TABLE office.roles
(
	role_id SERIAL				NOT NULL PRIMARY KEY,
	role_code				national character varying(12) NOT NULL,
	role_name				national character varying(50) NOT NULL,
	is_admin 				boolean NOT NULL CONSTRAINT roles_is_admin_df DEFAULT(false),
	is_system 				boolean NOT NULL CONSTRAINT roles_is_system_df DEFAULT(false),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

ALTER TABLE office.users
ADD FOREIGN KEY(role_id) REFERENCES office.roles(role_id);


CREATE UNIQUE INDEX roles_role_code_uix
ON office.roles(UPPER(role_code));

CREATE UNIQUE INDEX roles_role_name_uix
ON office.roles(UPPER(role_name));

INSERT INTO office.roles(role_code,role_name, is_system)
SELECT 'SYST', 'System', true;

INSERT INTO office.roles(role_code,role_name, is_admin)
SELECT 'ADMN', 'Administrators', true;

INSERT INTO office.roles(role_code,role_name)
SELECT 'USER', 'Users' UNION ALL
SELECT 'EXEC', 'Executive' UNION ALL
SELECT 'MNGR', 'Manager' UNION ALL
SELECT 'SALE', 'Sales' UNION ALL
SELECT 'MARK', 'Marketing' UNION ALL
SELECT 'LEGL', 'Legal & Compliance' UNION ALL
SELECT 'FINC', 'Finance' UNION ALL
SELECT 'HUMR', 'Human Resources' UNION ALL
SELECT 'INFO', 'Information Technology' UNION ALL
SELECT 'CUST', 'Customer Service';



CREATE FUNCTION office.get_office_id_by_user_id(user_id integer_strict)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT office.users.office_id FROM office.users
		WHERE office.users.user_id=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION office.get_office_id_by_office_code(office_code text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT office.offices.office_id FROM office.offices
		WHERE office.offices.office_code=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION office.get_user_id_by_user_name(user_name text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT office.users.user_id FROM office.users
		WHERE office.users.user_name=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION office.get_user_name_by_user_id(user_id integer)
RETURNS text
AS
$$
BEGIN
	RETURN
	(
		SELECT office.users.user_name FROM office.users
		WHERE office.users.user_id=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION office.get_role_id_by_use_id(user_id integer_strict)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT office.users.role_id FROM office.users
		WHERE office.users.user_id=$1
	);
END
$$
LANGUAGE plpgsql;


CREATE FUNCTION office.get_role_code_by_user_name(user_name text)
RETURNS text
AS
$$
BEGIN
	RETURN
	(
		SELECT office.roles.role_code FROM office.roles, office.users
		WHERE office.roles.role_id=office.users.role_id
		AND office.users.user_name=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE VIEW office.user_view
AS
SELECT
	office.users.user_id,
	office.users.user_name,
	office.users.full_name,
	office.roles.role_name,
	office.offices.office_name
FROM
	office.users
INNER JOIN office.roles
ON office.users.role_id = office.roles.role_id
INNER JOIN office.offices
ON office.users.office_id = office.offices.office_id;

CREATE FUNCTION office.get_sys_user_id()
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT office.users.user_id 
		FROM office.roles, office.users
		WHERE office.roles.role_id = office.users.role_id
		AND office.roles.is_system=true LIMIT 1
	);
END
$$
LANGUAGE plpgsql;



CREATE FUNCTION office.create_user
(
	role_id integer_strict,
	office_id integer_strict,
	user_name text,
	password text,
	full_name text
)
RETURNS VOID
AS
$$
BEGIN
	INSERT INTO office.users(role_id,office_id,user_name,password, full_name)
	SELECT $1, $2, $3, $4,$5;
	RETURN;
END
$$
LANGUAGE plpgsql;


SELECT office.create_user((SELECT role_id FROM office.roles WHERE role_code='SYST'),(SELECT office_id FROM office.offices WHERE office_code='PES'),'sys','','System');

/*******************************************************************
	TODO: REMOVE THIS USER ON DEPLOYMENT
*******************************************************************/
SELECT office.create_user((SELECT role_id FROM office.roles WHERE role_code='ADMN'),(SELECT office_id FROM office.offices WHERE office_code='PES'),'binod','+qJ9AMyGgrX/AOF4GmwmBa4SrA3+InlErVkJYmAopVZh+WFJD7k2ZO9dxox6XiqT38dSoM72jLoXNzwvY7JAQA==','Binod Nepal');

CREATE FUNCTION office.validate_login
(
	user_name text,
	password text
)
RETURNS boolean
AS
$$
BEGIN
	IF EXISTS
	(
		SELECT 1 FROM office.users 
		WHERE office.users.user_name=$1 
		AND office.users.password=$2 
		--The system user should not be allowed to login.
		AND office.users.role_id != 
		(
			SELECT office.roles.role_id 
			FROM office.roles 
			WHERE office.roles.role_code='SYST'
		)
	) THEN
		RETURN true;
	END IF;
	RETURN false;
END
$$
LANGUAGE plpgsql;



CREATE UNIQUE INDEX users_user_name_uix
ON office.users(UPPER(user_name));


CREATE TABLE audit.logins
(
	login_id 				BIGSERIAL NOT NULL PRIMARY KEY,
	user_id 				integer NOT NULL REFERENCES office.users(user_id),
	office_id 				integer NOT NULL REFERENCES office.offices(office_id),
	browser 				national character varying(500) NOT NULL,
	ip_address 				national character varying(50) NOT NULL,
	login_date_time 			TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(now()),
	remote_user 				national character varying(50) NOT NULL
);

CREATE FUNCTION office.get_login_id(_user_id integer)
RETURNS bigint
AS
$$
BEGIN
	RETURN
	(
		SELECT login_id
		FROM audit.logins
		WHERE user_id=$1
		AND login_date_time = 
		(
			SELECT MAX(login_date_time)
			FROM audit.logins
			WHERE user_id=$1
		)
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION office.get_logged_in_office_id(_user_id integer)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT office_id
		FROM audit.logins
		WHERE user_id=$1
		AND login_date_time = 
		(
			SELECT MAX(login_date_time)
			FROM audit.logins
			WHERE user_id=$1
		)
	);
END
$$
LANGUAGE plpgsql;

CREATE TABLE audit.failed_logins
(
	failed_login_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	user_id 				integer NULL REFERENCES office.users(user_id),
	user_name 				national character varying(50) NOT NULL,
	office_id 				integer NOT NULL REFERENCES office.offices(office_id),
	browser 				national character varying(500) NOT NULL,
	ip_address 				national character varying(50) NOT NULL,
	failed_date_time 			TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(now()),
	remote_user 				national character varying(50) NOT NULL,
	details 				national character varying(250) NULL
);


CREATE TABLE policy.lock_outs
(
	lock_out_id 				BIGSERIAL NOT NULL PRIMARY KEY,
	user_id 				integer NOT NULL REFERENCES office.users(user_id),
	lock_out_time 				TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW()),
	lock_out_till 				TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW() + '5 minutes'::interval)
);

--TODO: Create a lockout policy.
CREATE FUNCTION policy.perform_lock_out()
RETURNS TRIGGER
AS
$$
BEGIN
	IF(
		SELECT COUNT(*) FROM audit.failed_logins
		WHERE audit.failed_logins.user_id=NEW.user_id
		AND audit.failed_logins.failed_date_time 
		BETWEEN NOW()-'5minutes'::interval 
		AND NOW()
	)::integer>5 THEN

	INSERT INTO policy.lock_outs(user_id)SELECT NEW.user_id;
END IF;
RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER lockout_user
AFTER INSERT
ON audit.failed_logins
FOR EACH ROW EXECUTE PROCEDURE policy.perform_lock_out();

CREATE FUNCTION policy.is_locked_out_till(user_id integer_strict)
RETURNS TIMESTAMP
AS
$$
BEGIN
	RETURN
	(
		SELECT MAX(policy.lock_outs.lock_out_till)::TIMESTAMP WITHOUT TIME ZONE FROM policy.lock_outs
		WHERE policy.lock_outs.user_id=$1
	);
END
$$
LANGUAGE plpgsql;



CREATE TABLE core.price_types
(
	price_type_id 				SERIAL  NOT NULL PRIMARY KEY,
	price_type_code 			national character varying(12) NOT NULL,
	price_type_name 			national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX price_types_price_type_code_uix
ON core.price_types(UPPER(price_type_code));

CREATE UNIQUE INDEX price_types_price_type_name_uix
ON core.price_types(UPPER(price_type_name));


INSERT INTO core.price_types(price_type_code, price_type_name)
SELECT 'RET', 'Retail' UNION ALL
SELECT 'WHO', 'Wholesale';



CREATE TABLE core.menus
(
	menu_id 				SERIAL NOT NULL PRIMARY KEY,
	menu_text 				national character varying(250) NOT NULL,
	url 					national character varying(250) NULL,
	menu_code 				national character varying(12) NOT NULL,
	level 					smallint NOT NULL,
	parent_menu_id 				integer NULL REFERENCES core.menus(menu_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX menus_menu_code_uix
ON core.menus(UPPER(menu_code));

CREATE FUNCTION core.get_menu_id(menu_code text)
RETURNS INTEGER
AS
$$
BEGIN
	RETURN
	(
		SELECT core.menus.menu_id
		FROM core.menus
		WHERE core.menus.menu_code=$1
	);
END
$$
LANGUAGE plpgsql;



CREATE FUNCTION core.get_root_parent_menu_id(text)
RETURNS integer
AS
$$
	DECLARE retVal integer;
BEGIN
	WITH RECURSIVE find_parent(menu_id_group, parent, parent_menu_id, recentness) AS
	(
			SELECT menu_id, menu_id, parent_menu_id, 0
			FROM core.menus
			WHERE url=$1
			UNION ALL
			SELECT fp.menu_id_group, i.menu_id, i.parent_menu_id, fp.recentness + 1
			FROM core.menus i
			JOIN find_parent fp ON i.menu_id = fp.parent_menu_id
	)

		SELECT parent INTO retVal
		FROM find_parent q 
		JOIN
		(
				SELECT menu_id_group, MAX(recentness) AS answer
				FROM find_parent
				GROUP BY menu_id_group 
		) AS ans ON q.menu_id_group = ans.menu_id_group AND q.recentness = ans.answer 
		ORDER BY q.menu_id_group;

	RETURN retVal;
END
$$
LANGUAGE plpgsql;


INSERT INTO core.menus(menu_text, url, menu_code, level)
SELECT 'Dashboard', '/Dashboard/Index.aspx', 'DB', 0 UNION ALL
SELECT 'Sales', '/Sales/Index.aspx', 'SA', 0 UNION ALL
SELECT 'Purchase', '/Purchase/Index.aspx', 'PU', 0 UNION ALL
SELECT 'Products & Items', '/Items/Index.aspx', 'ITM', 0 UNION ALL
SELECT 'Finance', '/Finance/Index.aspx', 'FI', 0 UNION ALL
SELECT 'Manufacturing', '/Manufacturing/Index.aspx', 'MF', 0 UNION ALL
SELECT 'CRM', '/CRM/Index.aspx', 'CRM', 0 UNION ALL
SELECT 'Setup Parameters', '/Setup/Index.aspx', 'SE', 0 UNION ALL
SELECT 'POS', '/POS/Index.aspx', 'POS', 0;


INSERT INTO core.menus(menu_text, url, menu_code, level, parent_menu_id)
		  SELECT 'Sales & Quotation', NULL, 'SAQ', 1, core.get_menu_id('SA')
UNION ALL SELECT 'Direct Sales', '/Sales/DirectSales.aspx', 'DRS', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Sales Quotation', '/Sales/Quotation.aspx', 'SQ', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Sales Order', '/Sales/Order.aspx', 'SO', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Delivery for Sales Order', '/Sales/DeliveryForOrder.aspx', 'DSO', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Delivery Without Sales Order', '/Sales/DeliveryWithoutOrder.aspx', 'DWO', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Invoice for Sales Delivery', '/Sales/Invoice.aspx', 'ISD', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Receipt from Customer', '/Sales/Receipt.aspx', 'RFC', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Sales Return', '/Sales/Return.aspx', 'SR', 2, core.get_menu_id('SAQ')
UNION ALL SELECT 'Setup & Maintenance', NULL, 'SSM', 1, core.get_menu_id('SA')
UNION ALL SELECT 'Bonus Slab for Agents', '/Sales/Setup/AgentBonusSlabs.aspx', 'ABS', 2, core.get_menu_id('SSM')
UNION ALL SELECT 'Bonus Slab Details', '/Sales/Setup/AgentBonusSlabDetails.aspx', 'BSD', 2, core.get_menu_id('SSM')
UNION ALL SELECT 'Sales Agents', '/Sales/Setup/Agents.aspx', 'SSA', 2, core.get_menu_id('SSM')
UNION ALL SELECT 'Bonus Slab Assignment', '/Sales/Setup/BonusSlabAssignment.aspx', 'BSA', 2, core.get_menu_id('SSM')
UNION ALL SELECT 'Sales Reports', NULL, 'SAR', 1, core.get_menu_id('SA')
UNION ALL SELECT 'View Sales Inovice', '/Reports/Sales.View.Sales.Invoice.xml', 'SAR-SVSI', 2, core.get_menu_id('SAR')
UNION ALL SELECT 'Cashier Management', NULL, 'CM', 1, core.get_menu_id('POS')
UNION ALL SELECT 'Assign Cashier', '/POS/AssignCashier.aspx', 'ASC', 2, core.get_menu_id('CM')
UNION ALL SELECT 'POS Setup', NULL, 'POSS', 1, core.get_menu_id('POS')
UNION ALL SELECT 'Store Types', '/POS/Setup/StoreTypes.aspx', 'STT', 2, core.get_menu_id('POSS')
UNION ALL SELECT 'Stores', '/POS/Setup/Stores.aspx', 'STO', 2, core.get_menu_id('POSS')
UNION ALL SELECT 'Cash Repository Setup', '/Setup/CashRepositories.aspx', 'SCR', 2, core.get_menu_id('POSS')
UNION ALL SELECT 'Counter Setup', '/Setup/Counters.aspx', 'SCS', 2, core.get_menu_id('POSS')
UNION ALL SELECT 'Purchase & Quotation', NULL, 'PUQ', 1, core.get_menu_id('PU')
UNION ALL SELECT 'Direct Purchase', '/Purchase/DirectPurchase.aspx', 'DRP', 2, core.get_menu_id('PUQ')
UNION ALL SELECT 'Purchase Order', '/Purchase/Order.aspx', 'PO', 2, core.get_menu_id('PUQ')
UNION ALL SELECT 'GRN against PO', '/Purchase/GRN.aspx', 'GRN', 2, core.get_menu_id('PUQ')
UNION ALL SELECT 'Purchase Invoice Against GRN', '/Purchase/Invoice.aspx', 'PAY', 2, core.get_menu_id('PUQ')
UNION ALL SELECT 'Payment to Supplier', '/Purchase/Payment.aspx', 'PAS', 2, core.get_menu_id('PUQ')
UNION ALL SELECT 'Purchase Return', '/Purchase/Return.aspx', 'PR', 2, core.get_menu_id('PUQ')
UNION ALL SELECT 'Purchase Reports', NULL, 'PUR', 1, core.get_menu_id('PU')
UNION ALL SELECT 'Inventory Movements', NULL, 'IIM', 1, core.get_menu_id('ITM')
UNION ALL SELECT 'Stock Transfer Journal', '/Items/Transfer.aspx', 'STJ', 2, core.get_menu_id('IIM')
UNION ALL SELECT 'Stock Adjustments', '/Items/Adjustment.aspx', 'STA', 2, core.get_menu_id('IIM')
UNION ALL SELECT 'Setup & Maintenance', NULL, 'ISM', 1, core.get_menu_id('ITM')
UNION ALL SELECT 'Party Types', '/Items/Setup/PartyTypes.aspx', 'PT', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Party Accounts', '/Items/Setup/Parties.aspx', 'PA', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Shipping Addresses', '/Items/Setup/ShippingAddresses.aspx', 'PSA', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Item Maintenance', '/Items/Setup/Items.aspx', 'SSI', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Cost Prices', '/Items/Setup/CostPrices.aspx', 'ICP', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Selling Prices', '/Items/Setup/SellingPrices.aspx', 'ISP', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Item Groups', '/Items/Setup/ItemGroups.aspx', 'SSG', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Brands', '/Items/Setup/Brands.aspx', 'SSB', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Units of Measure', '/Items/Setup/UOM.aspx', 'UOM', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Compound Units of Measure', '/Items/Setup/CUOM.aspx', 'CUOM', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Shipper Information', '/Items/Setup/Shipper.aspx', 'SHI', 2, core.get_menu_id('ISM')
UNION ALL SELECT 'Transactions & Templates', NULL, 'FTT', 1, core.get_menu_id('FI')
UNION ALL SELECT 'Journal Voucher Entry', '/Finance/JournalVoucher.aspx', 'JVN', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Template Transaction', '/Finance/TemplateTransaction.aspx', 'TTR', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Standing Instructions', '/Finance/StandingInstructions.aspx', 'STN', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Update Exchange Rates', '/Finance/UpdateExchangeRates.aspx', 'UER', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Reconcile Bank Account', '/Finance/BankReconcilation.aspx', 'RBA', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Voucher Verification', '/Finance/VoucherVerification.aspx', 'FVV', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Transaction Document Manager', '/Finance/TransactionDocumentManager.aspx', 'FTDM', 2, core.get_menu_id('FTT')
UNION ALL SELECT 'Setup & Maintenance', NULL, 'FSM', 1, core.get_menu_id('FI')
UNION ALL SELECT 'Chart of Accounts', '/Finance/Setup/COA.aspx', 'COA', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Currency Management', '/Finance/Setup/Currencies.aspx', 'CUR', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Bank Accounts', '/Finance/Setup/BankAccounts.aspx', 'CBA', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Product GL Mapping', '/Finance/Setup/ProductGLMapping.aspx', 'PGM', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Budgets & Targets', '/Finance/Setup/BudgetAndTarget.aspx', 'BT', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Ageing Slabs', '/Finance/Setup/AgeingSlabs.aspx', 'AGS', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Tax Types', '/Finance/Setup/TaxTypes.aspx', 'TTY', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Tax Setup', '/Finance/Setup/TaxSetup.aspx', 'TS', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Cost Centers', '/Finance/Setup/CostCenters.aspx', 'CC', 2, core.get_menu_id('FSM')
UNION ALL SELECT 'Manufacturing Workflow', NULL, 'MFW', 1, core.get_menu_id('MF')
UNION ALL SELECT 'Sales Forecast', '/Manufacturing/Workflow/SalesForecast.aspx', 'MFWSF', 2, core.get_menu_id('MFW')
UNION ALL SELECT 'Master Production Schedule', '/Manufacturing/Workflow/MasterProductionSchedule.aspx', 'MFWMPS', 2, core.get_menu_id('MFW')
UNION ALL SELECT 'Manufacturing Setup', NULL, 'MFS', 1, core.get_menu_id('MF')
UNION ALL SELECT 'Work Centers', '/Manufacturing/Setup/WorkCenters.aspx', 'MFSWC', 2, core.get_menu_id('MFS')
UNION ALL SELECT 'Bills of Material', '/Manufacturing/Setup/BillsOfMaterial.aspx', 'MFSBOM', 2, core.get_menu_id('MFS')
UNION ALL SELECT 'Manufacturing Reports', NULL, 'MFR', 1, core.get_menu_id('MF')
UNION ALL SELECT 'Gross & Net Requirements', '/Manufacturing/Reports/GrossAndNetRequirements.aspx', 'MFRGNR', 2, core.get_menu_id('MFR')
UNION ALL SELECT 'Capacity vs Lead', '/Manufacturing/Reports/CapacityVersusLead.aspx', 'MFRCVSL', 2, core.get_menu_id('MFR')
UNION ALL SELECT 'Shop Floor Planning', '/Manufacturing/Reports/ShopFloorPlanning.aspx', 'MFRSFP', 2, core.get_menu_id('MFR')
UNION ALL SELECT 'Production Order Status', '/Manufacturing/Reports/ProductionOrderStatus.aspx', 'MFRPOS', 2, core.get_menu_id('MFR')
UNION ALL SELECT 'CRM Main', NULL, 'CRMM', 1, core.get_menu_id('CRM')
UNION ALL SELECT 'Add a New Lead', '/CRM/Lead.aspx', 'CRML', 2, core.get_menu_id('CRMM')
UNION ALL SELECT 'Add a New Opportunity', '/CRM/Opportunity.aspx', 'CRMO', 2, core.get_menu_id('CRMM')
UNION ALL SELECT 'Convert Lead to Opportunity', '/CRM/ConvertLeadToOpportunity.aspx', 'CRMC', 2, core.get_menu_id('CRMM')
UNION ALL SELECT 'Lead Followup', '/CRM/LeadFollowup.aspx', 'CRMFL', 2, core.get_menu_id('CRMM')
UNION ALL SELECT 'Opportunity Followup', '/CRM/OpportunityFollowup.aspx', 'CRMFO', 2, core.get_menu_id('CRMM')
UNION ALL SELECT 'Setup & Maintenance', NULL, 'CSM', 1, core.get_menu_id('CRM')
UNION ALL SELECT 'Lead Sources Setup', '/CRM/Setup/LeadSources.aspx', 'CRMLS', 2, core.get_menu_id('CSM')
UNION ALL SELECT 'Lead Status Setup', '/CRM/Setup/LeadStatuses.aspx', 'CRMLST', 2, core.get_menu_id('CSM')
UNION ALL SELECT 'Opportunity Stages Setup', '/CRM/Setup/OpportunityStages.aspx', 'CRMOS', 2, core.get_menu_id('CSM')
UNION ALL SELECT 'Office Setup', NULL, 'SOS', 1, core.get_menu_id('SE')
UNION ALL SELECT 'Office & Branch Setup', '/Setup/Offices.aspx', 'SOB', 2, core.get_menu_id('SOS')
UNION ALL SELECT 'Department Setup', '/Setup/Departments.aspx', 'SDS', 2, core.get_menu_id('SOS')
UNION ALL SELECT 'Role Management', '/Setup/Roles.aspx', 'SRM', 2, core.get_menu_id('SOS')
UNION ALL SELECT 'User Management', '/Setup/Users.aspx', 'SUM', 2, core.get_menu_id('SOS')
UNION ALL SELECT 'Fiscal Year Information', '/Setup/FiscalYear.aspx', 'SFY', 2, core.get_menu_id('SOS')
UNION ALL SELECT 'Frequency & Fiscal Year Management', '/Setup/Frequency.aspx', 'SFR', 2, core.get_menu_id('SOS')
UNION ALL SELECT 'Policy Management', NULL, 'SPM', 1, core.get_menu_id('SE')
UNION ALL SELECT 'Voucher Verification Policy', '/Setup/Policy/VoucherVerification.aspx', 'SVV', 2, core.get_menu_id('SPM')
UNION ALL SELECT 'Automatic Verification Policy', '/Setup/Policy/AutoVerification.aspx', 'SAV', 2, core.get_menu_id('SPM')
UNION ALL SELECT 'Menu Access Policy', '/Setup/Policy/MenuAccess.aspx', 'SMA', 2, core.get_menu_id('SPM')
UNION ALL SELECT 'GL Access Policy', '/Setup/Policy/GLAccess.aspx', 'SAP', 2, core.get_menu_id('SPM')
UNION ALL SELECT 'Store Policy', '/Setup/Policy/Store.aspx', 'SSP', 2, core.get_menu_id('SPM')
UNION ALL SELECT 'Switches', '/Setup/Policy/Switches.aspx', 'SWI', 2, core.get_menu_id('SPM')
UNION ALL SELECT 'Admin Tools', NULL, 'SAT', 1, core.get_menu_id('SE')
UNION ALL SELECT 'SQL Query Tool', '/Setup/Admin/Query.aspx', 'SQL', 2, core.get_menu_id('SAT')
UNION ALL SELECT 'Database Statistics', '/Setup/Admin/DatabaseStatistics.aspx', 'DBSTAT', 2, core.get_menu_id('SAT')
UNION ALL SELECT 'Backup Database', '/Setup/Admin/Backup.aspx', 'BAK', 2, core.get_menu_id('SAT')
UNION ALL SELECT 'Restore Database', '/Setup/Admin/Restore.aspx', 'RES', 2, core.get_menu_id('SAT')
UNION ALL SELECT 'Change User Password', '/Setup/Admin/ChangePassword.aspx', 'PWD', 2, core.get_menu_id('SAT')
UNION ALL SELECT 'New Company', '/Setup/Admin/NewCompany.aspx', 'NEW', 2, core.get_menu_id('SAT');



CREATE VIEW office.login_view
AS
SELECT
	users.user_id, 
	roles.role_code || ' (' || roles.role_name || ')' AS role, 
	roles.is_admin,
	roles.is_system,
	users.user_name, 
	users.full_name,
	office.get_login_id(office.users.user_id) AS login_id,
	office.get_logged_in_office_id(office.users.user_id) AS office_id,
	logged_in_office.office_code || ' (' || logged_in_office.office_name || ')' AS office,
	logged_in_office.office_code,
	logged_in_office.office_name,
	logged_in_office.nick_name,
	logged_in_office.registration_date,
	logged_in_office.registration_number,
	logged_in_office.pan_number,
	logged_in_office.address_line_1,
	logged_in_office.address_line_2,
	logged_in_office.street,
	logged_in_office.city,
	logged_in_office.state,
	logged_in_office.country,
	logged_in_office.zip_code,
	logged_in_office.phone,
	logged_in_office.fax,
	logged_in_office.email,
	logged_in_office.url
FROM 
	office.users
INNER JOIN
	office.roles
ON
	users.role_id = roles.role_id 
INNER JOIN
	office.offices
ON
	users.office_id = offices.office_id
LEFT JOIN
	office.offices AS logged_in_office
ON
	logged_in_office.office_id = office.get_logged_in_office_id(office.users.user_id);


CREATE OR REPLACE VIEW office.role_view
AS
SELECT 
  roles.role_id, 
  roles.role_code, 
  roles.role_name
FROM 
  office.roles;


CREATE VIEW core.relationship_view
AS
SELECT
	tc.table_schema,
	tc.table_name,
	kcu.column_name,
	ccu.table_schema AS references_schema,
	ccu.table_name AS references_table,
	ccu.column_name AS references_field  
FROM
	information_schema.table_constraints tc  
LEFT JOIN
	information_schema.key_column_usage kcu  
		ON tc.constraint_catalog = kcu.constraint_catalog  
		AND tc.constraint_schema = kcu.constraint_schema  
		AND tc.constraint_name = kcu.constraint_name  
LEFT JOIN
	information_schema.referential_constraints rc  
		ON tc.constraint_catalog = rc.constraint_catalog  
		AND tc.constraint_schema = rc.constraint_schema  
		AND tc.constraint_name = rc.constraint_name	
LEFT JOIN
	information_schema.constraint_column_usage ccu  
		ON rc.unique_constraint_catalog = ccu.constraint_catalog  
		AND rc.unique_constraint_schema = ccu.constraint_schema  
		AND rc.unique_constraint_name = ccu.constraint_name  
WHERE
	lower(tc.constraint_type) in ('foreign key');


CREATE FUNCTION core.parse_default(text)
RETURNS text
AS
$$
DECLARE _sql text;
DECLARE _val text;
BEGIN
	IF($1 LIKE '%::%' AND $1 NOT LIKE 'nextval%') THEN
		_sql := 'SELECT ' || $1;
		EXECUTE _sql INTO _val;
		RETURN _val;
	END IF;

	RETURN $1;
END
$$
LANGUAGE plpgsql;

CREATE VIEW core.mixerp_table_view
AS
SELECT information_schema.columns.table_schema, 
	   information_schema.columns.table_name, 
	   information_schema.columns.column_name, 
	   references_schema, 
	   references_table, 
	   references_field, 
	   ordinal_position,
	   is_nullable,
	   core.parse_default(column_default) AS column_default, 
	   data_type, 
	   domain_name,
	   character_maximum_length, 
	   character_octet_length, 
	   numeric_precision, 
	   numeric_precision_radix, 
	   numeric_scale, 
	   datetime_precision, 
	   udt_name 
FROM   information_schema.columns 
	   LEFT JOIN core.relationship_view 
			  ON information_schema.columns.table_schema = 
				 core.relationship_view.table_schema 
				 AND information_schema.columns.table_name = 
					 core.relationship_view.table_name 
				 AND information_schema.columns.column_name = 
					 core.relationship_view.column_name 
WHERE  information_schema.columns.table_schema 
NOT IN 
	( 
		'pg_catalog', 'information_schema'
	)
AND 	   information_schema.columns.column_name 
NOT IN
	(
		'audit_user_id', 'audit_ts'
	)
;
	
	
CREATE TABLE core.frequencies
(
	frequency_id 				SERIAL NOT NULL PRIMARY KEY,
	frequency_code 				national character varying(12) NOT NULL,
	frequency_name 				national character varying(50) NOT NULL
);


CREATE UNIQUE INDEX frequencies_frequency_code_uix
ON core.frequencies(UPPER(frequency_code));

CREATE UNIQUE INDEX frequencies_frequency_name_uix
ON core.frequencies(UPPER(frequency_name));

INSERT INTO core.frequencies
SELECT 2, 'EOM', 'End of Month' UNION ALL
SELECT 3, 'EOQ', 'End of Quarter' UNION ALL
SELECT 4, 'EOH', 'End of Half' UNION ALL
SELECT 5, 'EOY', 'End of Year';


CREATE TABLE core.fiscal_year
(
	fiscal_year_code 			national character varying(12) NOT NULL PRIMARY KEY,
	fiscal_year_name 			national character varying(50) NOT NULL,
	starts_from 				date NOT NULL,
	ends_on 				date NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX fiscal_year_fiscal_year_name_uix
ON core.fiscal_year(UPPER(fiscal_year_name));

CREATE UNIQUE INDEX fiscal_year_starts_from_uix
ON core.fiscal_year(starts_from);

CREATE UNIQUE INDEX fiscal_year_ends_on_uix
ON core.fiscal_year(ends_on);


CREATE TABLE core.frequency_setups
(
	frequency_setup_id			SERIAL NOT NULL PRIMARY KEY,
	fiscal_year_code 			national character varying(12) NOT NULL REFERENCES core.fiscal_year(fiscal_year_code),
	value_date 				date NOT NULL UNIQUE,
	frequency_id 				integer NOT NULL REFERENCES core.frequencies(frequency_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

--TODO: Validation constraints for core.frequency_setups

CREATE TABLE core.units
(
	unit_id 				SERIAL NOT NULL PRIMARY KEY,
	unit_code 				national character varying(12) NOT NULL,
	unit_name 				national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX units_unit_code_uix
ON core.units(UPPER(unit_code));

CREATE UNIQUE INDEX "units_unit_name_uix"
ON core.units(UPPER(unit_name));

INSERT INTO core.units(unit_code, unit_name)
SELECT 'PC', 'Piece' UNION ALL
SELECT 'FT', 'Feet' UNION ALL
SELECT 'MTR', 'Meter' UNION ALL
SELECT 'LTR', 'Liter' UNION ALL
SELECT 'GM', 'Gram' UNION ALL
SELECT 'KG', 'Kilogram' UNION ALL
SELECT 'DZ', 'Dozen' UNION ALL
SELECT 'BX', 'Box';

CREATE FUNCTION core.get_unit_id_by_unit_code(text)
RETURNS smallint
AS
$$
BEGIN
	RETURN
	(
		SELECT
			core.units.unit_id
		FROM
			core.units
		WHERE
			core.units.unit_code=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.get_unit_id_by_unit_name(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT
			core.units.unit_id
		FROM
			core.units
		WHERE
			core.units.unit_name=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE TABLE core.compound_units
(
	compound_unit_id 			SERIAL NOT NULL PRIMARY KEY,
	base_unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	value 					smallint NOT NULL,
	compare_unit_id 			integer NOT NULL REFERENCES core.units(unit_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
						CONSTRAINT compound_units_check CHECK(base_unit_id != compare_unit_id)
);

CREATE UNIQUE INDEX compound_units_info_uix
ON core.compound_units(base_unit_id, compare_unit_id);

INSERT INTO core.compound_units(base_unit_id, compare_unit_id, value)
SELECT core.get_unit_id_by_unit_code('PC'), core.get_unit_id_by_unit_code('DZ'), 12 UNION ALL
SELECT core.get_unit_id_by_unit_code('DZ'), core.get_unit_id_by_unit_code('BX'), 100 UNION ALL
SELECT core.get_unit_id_by_unit_code('GM'), core.get_unit_id_by_unit_code('KG'), 1000;

CREATE FUNCTION core.get_root_unit_id(integer)
RETURNS integer
AS
$$
	DECLARE root_unit_id integer;
BEGIN
	SELECT base_unit_id INTO root_unit_id
	FROM core.compound_units
	WHERE compare_unit_id=$1;

	IF(root_unit_id IS NULL) THEN
		RETURN $1;
	ELSE
		RETURN core.get_root_unit_id(root_unit_id);
	END IF;	
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.is_parent_unit(parent integer, child integer)
RETURNS boolean
AS
$$		
BEGIN
	IF $1!=$2 THEN
		IF EXISTS
		(
			WITH RECURSIVE unit_cte(unit_id) AS 
			(
			 SELECT tn.compare_unit_id
				FROM core.compound_units AS tn WHERE tn.base_unit_id = $1
			UNION ALL
			 SELECT
				c.compare_unit_id
				FROM unit_cte AS p, 
			  core.compound_units AS c 
				WHERE base_unit_id = p.unit_id
			)

			SELECT * FROM unit_cte
			WHERE unit_id=$2
		) THEN
			RETURN TRUE;
		END IF;
	END IF;
	RETURN false;
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.convert_unit(integer, integer)
RETURNS decimal
AS
$$
	DECLARE _factor decimal;
BEGIN
	IF(core.get_root_unit_id($1) != core.get_root_unit_id($2)) THEN
		RETURN 0;
	END IF;

	IF($1 = $2) THEN
		RETURN 1.00;
	END IF;
	
	IF(core.is_parent_unit($1, $2)) THEN
			WITH RECURSIVE unit_cte(unit_id, value) AS 
			(
				SELECT tn.compare_unit_id, tn.value
				FROM core.compound_units AS tn WHERE tn.base_unit_id = $1

				UNION ALL

				SELECT 
				c.compare_unit_id, c.value * p.value
				FROM unit_cte AS p, 
				core.compound_units AS c 
				WHERE base_unit_id = p.unit_id
			)
		SELECT 1.00/value INTO _factor
		FROM unit_cte
		WHERE unit_id=$2;
	ELSE
			WITH RECURSIVE unit_cte(unit_id, value) AS 
			(
			 SELECT tn.compare_unit_id, tn.value
				FROM core.compound_units AS tn WHERE tn.base_unit_id = $2
			UNION ALL
			 SELECT 
				c.compare_unit_id, c.value * p.value
				FROM unit_cte AS p, 
			  core.compound_units AS c 
				WHERE base_unit_id = p.unit_id
			)

		SELECT value INTO _factor
		FROM unit_cte
		WHERE unit_id=$1;
	END IF;

	RETURN _factor;
END
$$
LANGUAGE plpgsql;


CREATE FUNCTION core.get_associated_units(integer)
RETURNS TABLE(unit_id integer, unit_code text, unit_name text)
AS
$$
	DECLARE root_unit_id integer;
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS temp_unit(unit_id integer) ON COMMIT DROP;	
	
	SELECT core.get_root_unit_id($1) INTO root_unit_id;
	
	INSERT INTO temp_unit(unit_id) 
	SELECT root_unit_id
	WHERE NOT EXISTS
	(
		SELECT * FROM temp_unit
		WHERE temp_unit.unit_id=root_unit_id
	);
	
	WITH RECURSIVE cte(unit_id)
	AS
	(
		 SELECT 
			compare_unit_id
		 FROM 
			core.compound_units
		 WHERE 
			base_unit_id = root_unit_id

		UNION ALL

		 SELECT
			units.compare_unit_id
		 FROM 
			core.compound_units units
		 INNER JOIN cte 
		 ON cte.unit_id = units.base_unit_id
	)
	
	INSERT INTO temp_unit(unit_id)
	SELECT cte.unit_id FROM cte;
	
	DELETE FROM temp_unit
	WHERE temp_unit.unit_id IS NULL;
	
	RETURN QUERY 
	SELECT 
		core.units.unit_id,
		core.units.unit_code::text,
		core.units.unit_name::text
	FROM
		core.units
	WHERE
		core.units.unit_id 
	IN
	(
		SELECT temp_unit.unit_id FROM temp_unit
	);
END
$$
LANGUAGE plpgsql;


CREATE FUNCTION core.get_associated_units_from_item_id(integer)
RETURNS TABLE(unit_id integer, unit_code text, unit_name text)
AS
$$
DECLARE _unit_id integer;
BEGIN
	SELECT core.items.unit_id INTO _unit_id
	FROM core.items
	WHERE core.items.item_id=$1;

	RETURN QUERY
	SELECT ret.unit_id, ret.unit_code, ret.unit_name
	FROM core.get_associated_units(_unit_id) AS ret;

END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.get_associated_units_from_item_code(text)
RETURNS TABLE(unit_id integer, unit_code text, unit_name text)
AS
$$
DECLARE _unit_id integer;
BEGIN
	SELECT core.items.unit_id INTO _unit_id
	FROM core.items
	WHERE core.items.item_code=$1;

	RETURN QUERY
	SELECT ret.unit_id, ret.unit_code, ret.unit_name
	FROM core.get_associated_units(_unit_id) AS ret;

END
$$
LANGUAGE plpgsql;


CREATE VIEW core.compound_unit_view
AS
SELECT
	compound_unit_id,
	base_unit.unit_name base_unit_name,
	value,
	compare_unit.unit_name compare_unit_name
FROM
	core.compound_units,
	core.units base_unit,
	core.units compare_unit
WHERE
	core.compound_units.base_unit_id = base_unit.unit_id
AND
	core.compound_units.compare_unit_id = compare_unit.unit_id;


--TODO
CREATE VIEW core.unit_view
AS
SELECT * FROM core.units;

CREATE FUNCTION core.get_base_quantity_by_unit_name(text, integer)
RETURNS decimal
AS
$$
DECLARE _unit_id integer;
DECLARE _root_unit_id integer;
DECLARE _factor decimal;
BEGIN
	_unit_id := core.get_unit_id_by_unit_name($1);
	_root_unit_id = core.get_root_unit_id(_unit_id);
	_factor = core.convert_unit(_unit_id, _root_unit_id);

	RETURN _factor * $2;
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.get_base_unit_id_by_unit_name(text)
RETURNS integer
AS
$$
DECLARE _unit_id integer;
BEGIN
	_unit_id := core.get_unit_id_by_unit_name($1);

	RETURN
	(
		core.get_root_unit_id(_unit_id)
	);
END
$$
LANGUAGE plpgsql;

CREATE TABLE core.account_masters
(
	account_master_id 			SERIAL NOT NULL PRIMARY KEY,
	account_master_code 			national character varying(3) NOT NULL,
	account_master_name 			national character varying(40) NOT NULL	
);

CREATE UNIQUE INDEX account_master_code_uix
ON core.account_masters(UPPER(account_master_code));

CREATE UNIQUE INDEX account_master_name_uix
ON core.account_masters(UPPER(account_master_name));



CREATE TABLE core.accounts
(
	account_id				SERIAL NOT NULL PRIMARY KEY,
	account_master_id 			integer NOT NULL REFERENCES core.account_masters(account_master_id),
	account_code      			national character varying(12) NOT NULL,
	external_code     			national character varying(12) NULL CONSTRAINT accounts_external_code_df DEFAULT(''),
	confidential      			boolean NOT NULL CONSTRAINT accounts_confidential_df DEFAULT(false),
	account_name      			national character varying(100) NOT NULL,
	description	  			national character varying(200) NULL,
	sys_type 	  			boolean NOT NULL CONSTRAINT accounts_sys_type_df DEFAULT(false),
	is_cash		  			boolean NOT NULL CONSTRAINT accounts_is_cash_df DEFAULT(false),
	parent_account_id 			integer NULL REFERENCES core.accounts(account_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX accountsCode_uix
ON core.accounts(UPPER(account_code));

CREATE UNIQUE INDEX accounts_Name_uix
ON core.accounts(UPPER(account_name));

CREATE FUNCTION core.has_child_accounts(integer)
RETURNS boolean
AS
$$
BEGIN
	IF EXISTS(SELECT 0 FROM core.accounts WHERE parent_account_id=$1 LIMIT 1) THEN
		RETURN true;
	END IF;

	RETURN false;
END
$$
LANGUAGE plpgsql;


CREATE FUNCTION core.get_cash_account_id()
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT account_id
		FROM core.accounts
		WHERE is_cash=true
		LIMIT 1
	);
END
$$
LANGUAGE plpgsql;

CREATE VIEW core.account_view
AS
SELECT
	core.accounts.account_id,
	core.account_masters.account_master_code,
	core.accounts.account_code,
	core.accounts.external_code,
	core.accounts.account_name,
	core.accounts.confidential,
	core.accounts.description,
	core.accounts.sys_type,
	core.accounts.is_cash,
	parent_account.account_code || ' (' || parent_account.account_name || ')' AS parent,
	core.has_child_accounts(core.accounts.account_id) AS has_child
FROM core.accounts
INNER JOIN core.account_masters
ON core.account_masters.account_master_id=core.accounts.account_master_id
LEFT JOIN core.accounts parent_account
ON parent_account.account_id=core.accounts.parent_account_id;

INSERT INTO core.account_masters(account_master_code, account_master_name) SELECT 'BSA', 'Balance Sheet A/C';
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10000', 'Assets', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Balance Sheet A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10001', 'Current Assets', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10100', 'Cash at Bank A/C', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10110', 'Regular Checking Account', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cash at Bank A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10120', 'Payroll Checking Account', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cash at Bank A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10130', 'Savings Account', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cash at Bank A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10140', 'Special Account', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cash at Bank A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id, is_cash) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10200', 'Cash in Hand A/C', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets'), true;
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10300', 'Investments', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10310', 'Short Term Investment', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Investments');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10320', 'Other Investments', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Investments');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10321', 'Investments-Money Market', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Investments');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10322', 'Bank Deposit Contract (Fixed Deposit)', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Investments');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10323', 'Investments-Certificates of Deposit', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Investments');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10400', 'Accounts Receivable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10500', 'Other Receivables', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10600', 'Allowance for Doubtful Accounts', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10700', 'Inventory', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10720', 'Raw Materials Inventory', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Inventory');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10730', 'Supplies Inventory', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Inventory');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10740', 'Work in Progress Inventory', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Inventory');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10750', 'Finished Goods Inventory', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Inventory');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10800', 'Prepaid Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '10900', 'Employee Advances', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '11000', 'Notes Receivable-Current', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '11100', 'Prepaid Interest', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '11200', 'Accrued Incomes (Assets)', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '11300', 'Other Debtors', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '11400', 'Other Current Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12001', 'Noncurrent Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12100', 'Furniture and Fixtures', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12200', 'Plants & Equipments', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12300', 'Rental Property', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12400', 'Vehicles', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12500', 'Intangibles', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12600', 'Other Depreciable Properties', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12700', 'Leasehold Improvements', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12800', 'Buildings', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '12900', 'Building Improvements', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13000', 'Interior Decorations', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13100', 'Land', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13200', 'Long Term Investments', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13300', 'Trade Debtors', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13400', 'Rental Debtors', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13500', 'Staff Debtors', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13600', 'Other Noncurrent Debtors', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13700', 'Other Financial Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13710', 'Deposits Held', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Financial Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13800', 'Accumulated Depreciations', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13810', 'Accumulated Depreciation-Furniture and Fixtures', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13820', 'Accumulated Depreciation-Equipment', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13830', 'Accumulated Depreciation-Vehicles', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13840', 'Accumulated Depreciation-Other Depreciable Properties', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13850', 'Accumulated Depreciation-Leasehold', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13860', 'Accumulated Depreciation-Buildings', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13870', 'Accumulated Depreciation-Building Improvements', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '13880', 'Accumulated Depreciation-Interior Decorations', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Accumulated Depreciations');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14001', 'Other Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14100', 'Other Assets-Deposits', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14200', 'Other Assets-Organization Costs', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14300', 'Other Assets-Accumulated Amortization-Organization Costs', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14400', 'Notes Receivable-Non-current', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14500', 'Other Non-current Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '14600', 'Nonfinancial Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Assets');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20000', 'Liabilities', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Balance Sheet A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20001', 'Current Liabilities', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20100', 'Accounts Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20110', 'Shipping Charge Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20200', 'Accrued Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20300', 'Wages Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20400', 'Deductions Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20500', 'Health Insurance Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20600', 'Superannutation Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20700', 'Tax Payables', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20710', 'Sales Tax Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20720', 'Federal Payroll Taxes Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20730', 'FUTA Tax Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20740', 'State Payroll Taxes Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20750', 'SUTA Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20760', 'Local Payroll Taxes Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20770', 'Income Taxes Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20780', 'Other Taxes Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Tax Payables');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20800', 'Employee Benefits Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20810', 'Provision for Annual Leave', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefits Payable');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20820', 'Provision for Long Service Leave', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefits Payable');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20830', 'Provision for Personal Leave', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefits Payable');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20840', 'Provision for Health Leave', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefits Payable');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '20900', 'Current Portion of Long-term Debt', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21000', 'Advance Incomes', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21010', 'Advance Sales Income', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Advance Incomes');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21020', 'Grant Received in Advance', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Advance Incomes');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21100', 'Deposits from Customers', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21200', 'Other Current Liabilities', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21210', 'Short Term Loan Payables', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21220', 'Short Term Hirepurchase Payables', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21230', 'Short Term Lease Liability', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '21240', 'Grants Repayable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Current Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24001', 'Noncurrent Liabilities', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24100', 'Notes Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24200', 'Land Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24300', 'Equipment Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24400', 'Vehicles Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24500', 'Lease Liability', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24600', 'Loan Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24700', 'Hirepurchase Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24800', 'Bank Loans Payable', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '24900', 'Deferred Revenue', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '25000', 'Other Long-term Liabilities', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Noncurrent Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '25010', 'Long Term Employee Benefit Provision', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Other Long-term Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28001', 'Equity', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Liabilities');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28100', 'Stated Capital', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28110', 'Founder Capital', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Stated Capital');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28120', 'Promoter Capital', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Stated Capital');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28130', 'Member Capital', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Stated Capital');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28200', 'Capital Surplus', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28210', 'Share Premium', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28220', 'Capital Redemption Reserves', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28230', 'Statutory Reserves', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28240', 'Asset Revaluation Reserves', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28250', 'Exchange Rate Fluctuation Reserves', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28260', 'Capital Reserves Arising From Merger', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28270', 'Capital Reserves Arising From Acuisition', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Capital Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28300', 'Retained Surplus', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28310', 'Accumulated Profits', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Retained Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28320', 'Accumulated Losses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Retained Surplus');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28400', 'Treasury Stock', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28500', 'Current Year Surplus', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28600', 'General Reserves', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '28700', 'Other Reserves', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Equity');
INSERT INTO core.account_masters(account_master_code, account_master_name) SELECT 'PLA', 'Profit and Loss A/C';
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30000', 'Revenues', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Profit and Loss A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30100', 'Sales A/C', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30200', 'Interest Income', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30300', 'Other Income', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30400', 'Finance Charge Income', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30500', 'Shipping Charges Reimbursed', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30600', 'Sales Returns and Allowances', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '30700', 'Sales Discounts', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Revenues');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40000', 'Expenses', TRUE, (SELECT account_id FROM core.accounts WHERE account_name='Profit and Loss A/C');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40100', 'Purchase A/C', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40200', 'Cost of GoodS Sold', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40205', 'Product Cost', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40210', 'Raw Material Purchases', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40215', 'Direct Labor Costs', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40220', 'Indirect Labor Costs', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40225', 'Heat and Power', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40230', 'Commissions', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40235', 'Miscellaneous Factory Costs', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40240', 'Cost of Goods Sold-Salaries and Wages', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40245', 'Cost of Goods Sold-Contract Labor', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40250', 'Cost of Goods Sold-Freight', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40255', 'Cost of Goods Sold-Other', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40260', 'Inventory Adjustments', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40265', 'Purchase Returns and Allowances', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40270', 'Purchase Discounts', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Cost of GoodS Sold');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40300', 'General Purchase Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40400', 'Advertising Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40500', 'Amortization Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40600', 'Auto Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40700', 'Bad Debt Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40800', 'Bank Fees', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '40900', 'Cash Over and Short', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41000', 'Charitable Contributions Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41100', 'Commissions and Fees Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41200', 'Depreciation Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41300', 'Dues and Subscriptions Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41400', 'Employee Benefit Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41410', 'Employee Benefit Expenses-Health Insurance', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefit Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41420', 'Employee Benefit Expenses-Pension Plans', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefit Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41430', 'Employee Benefit Expenses-Profit Sharing Plan', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefit Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41440', 'Employee Benefit Expenses-Other', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Employee Benefit Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41500', 'Freight Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41600', 'Gifts Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41700', 'Income Tax Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41710', 'Income Tax Expenses-Federal', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Income Tax Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41720', 'Income Tax Expenses-State', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Income Tax Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41730', 'Income Tax Expenses-Local', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Income Tax Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41800', 'Insurance Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41810', 'Insurance Expenses-Product Liability', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Insurance Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41820', 'Insurance Expenses-Vehicle', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Insurance Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '41900', 'Interest Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42000', 'Laundry and Dry Cleaning Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42100', 'Legal and Professional Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42200', 'Licenses Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42300', 'Loss on NSF Checks', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42400', 'Maintenance Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42500', 'Meals and Entertainment Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42600', 'Office Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42700', 'Payroll Tax Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42800', 'Penalties and Fines Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '42900', 'Other Taxe Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43000', 'Postage Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43100', 'Rent or Lease Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43200', 'Repair and Maintenance Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43210', 'Repair and Maintenance Expenses-Office', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Repair and Maintenance Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43220', 'Repair and Maintenance Expenses-Vehicle', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Repair and Maintenance Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43300', 'Supplies Expenses-Office', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43400', 'Telephone Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43500', 'Training Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43600', 'Travel Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43700', 'Salary Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43800', 'Wages Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '43900', 'Utilities Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '44000', 'Other Expenses', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.accounts(account_master_id,account_code,account_name, sys_type, parent_account_id) SELECT (SELECT account_master_id FROM core.account_masters WHERE account_master_code='BSA'), '44100', 'Gain/Loss on Sale of Assets', FALSE, (SELECT account_id FROM core.accounts WHERE account_name='Expenses');
INSERT INTO core.account_masters(account_master_code, account_master_name) SELECT 'OBS', 'Off Balance Sheet A/C';

CREATE FUNCTION core.disable_editing_sys_type()
RETURNS TRIGGER
AS
$$
BEGIN
	IF TG_OP='UPDATE' OR TG_OP='DELETE' THEN
		IF EXISTS
		(
			SELECT *
			FROM core.accounts
			WHERE (sys_type=true OR is_cash=true)
			AND account_id=OLD.account_id
		) THEN
			RAISE EXCEPTION 'You are not allowed to change system accounts.';
		END IF;
		RETURN OLD;
	END IF;
	
	IF TG_OP='INSERT' THEN
		IF (NEW.sys_type=true OR NEW.is_cash=true) THEN
			RAISE EXCEPTION 'You are not allowed to add system accounts.';
		END IF;
		RETURN NEW;
	END IF;

END
$$
LANGUAGE plpgsql;

CREATE TRIGGER restrict_delete_sys_type_trigger
BEFORE DELETE
ON core.accounts
FOR EACH ROW EXECUTE PROCEDURE core.disable_editing_sys_type();

CREATE TRIGGER restrict_update_sys_type_trigger
BEFORE UPDATE
ON core.accounts
FOR EACH ROW EXECUTE PROCEDURE core.disable_editing_sys_type();

CREATE TRIGGER restrict_insert_sys_type_trigger
BEFORE INSERT
ON core.accounts
FOR EACH ROW EXECUTE PROCEDURE core.disable_editing_sys_type();

CREATE VIEW core.accounts_view
AS
SELECT
	core.accounts.account_id,
	core.accounts.account_code,
	core.accounts.account_name,
	core.accounts.description,
	core.accounts.sys_type,
	core.accounts.parent_account_id,
	parent_accounts.account_code AS parent_account_code,
	parent_accounts.account_name AS parent_account_name,
	core.account_masters.account_master_id,
	core.account_masters.account_master_code,
	core.account_masters.account_master_name
FROM
	core.account_masters
	INNER JOIN core.accounts 
	ON core.account_masters.account_master_id = core.accounts.account_master_id
	LEFT OUTER JOIN core.accounts AS parent_accounts 
	ON core.accounts.parent_account_id = parent_accounts.account_id;


CREATE FUNCTION core.get_account_id_by_account_code(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT account_id
		FROM core.accounts
		WHERE account_code=$1
	);
END
$$
LANGUAGE plpgsql;


CREATE TABLE core.account_parameters
(
	account_parameter_id 			SERIAL NOT NULL CONSTRAINT account_parameters_pk PRIMARY KEY,
	parameter_name 				national character varying(128) NOT NULL,
	account_id 				integer NOT NULL REFERENCES core.accounts(account_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX account_parameters_parameter_name_uix
ON core.account_parameters(UPPER(parameter_name));

INSERT INTO core.account_parameters(parameter_name, account_id)
SELECT 'Sales', core.get_account_id_by_account_code('30100') UNION ALL
SELECT 'Sales.Receivables', core.get_account_id_by_account_code('10400') UNION ALL
SELECT 'Sales.Discount', core.get_account_id_by_account_code('30700') UNION ALL
SELECT 'Sales.Tax', core.get_account_id_by_account_code('20700') UNION ALL
SELECT 'Purchase', core.get_account_id_by_account_code('40100') UNION ALL
SELECT 'Purchase.Payables', core.get_account_id_by_account_code('20100') UNION ALL
SELECT 'Purchase.Discount', core.get_account_id_by_account_code('40270') UNION ALL
SELECT 'Purchase.Tax', core.get_account_id_by_account_code('20700') UNION ALL
SELECT 'Inventory', core.get_account_id_by_account_code('10700') UNION ALL
SELECT 'COGS', core.get_account_id_by_account_code('40200');

CREATE FUNCTION core.get_account_id_by_parameter(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT
			account_id
		FROM	
			core.account_parameters
		WHERE
			parameter_name=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.get_account_name(integer)
RETURNS text
AS
$$
BEGIN
	RETURN
	(
		SELECT
			account_name
		FROM	
			core.accounts
		WHERE
			account_id=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE TABLE core.bank_accounts
(
	account_id 				integer NOT NULL CONSTRAINT bank_accounts_pk PRIMARY KEY
								CONSTRAINT bank_accounts_accounts_fk REFERENCES core.accounts(account_id),
	maintained_by_user_id 			integer NOT NULL CONSTRAINT bank_accounts_users_fk REFERENCES office.users(user_id),
	bank_name 				national character varying(128) NOT NULL,
	bank_branch 				national character varying(128) NOT NULL,
	bank_contact_number 			national character varying(128) NULL,
	bank_address 				text NULL,
	bank_account_code 			national character varying(128) NULL,
	bank_account_type 			national character varying(128) NULL,
	relationship_officer_name		national character varying(128) NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE VIEW core.bank_account_view
AS
SELECT
	core.accounts.account_id,
	core.accounts.account_code,
	core.accounts.account_name,
	office.users.user_name AS maintained_by,
	core.bank_accounts.bank_name,
	core.bank_accounts.bank_branch,
	core.bank_accounts.bank_contact_number,
	core.bank_accounts.bank_address,
	core.bank_accounts.bank_account_code,
	core.bank_accounts.bank_account_type,
	core.bank_accounts.relationship_officer_name AS relation_officer
FROM
	core.bank_accounts
INNER JOIN core.accounts ON core.accounts.account_id = core.bank_accounts.account_id
INNER JOIN office.users ON core.bank_accounts.maintained_by_user_id = office.users.user_id;

CREATE TABLE core.agents
(
	agent_id				SERIAL NOT NULL PRIMARY KEY,
	agent_code				national character varying(12) NOT NULL,
	agent_name 				national character varying(100) NOT NULL,
	address 				national character varying(100) NOT NULL,
	contact_number 				national character varying(50) NOT NULL,
	commission_rate 			decimal_strict2 NOT NULL DEFAULT(0),
	account_id 				integer NOT NULL REFERENCES core.accounts(account_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX agents_agent_name_uix
ON core.agents(UPPER(agent_name));

INSERT INTO core.agents(agent_code, agent_name, address, contact_number, commission_rate, account_id)
SELECT 'OFF', 'Office', 'Office', '', 0, (SELECT account_id FROM core.accounts WHERE account_code='20100');

CREATE VIEW core.agent_view
AS
SELECT
	agent_id,
	agent_code,
	agent_name,
	address,
	contact_number,
	commission_rate,
	account_name
FROM
	core.agents,
	core.accounts
WHERE
	core.agents.account_id = core.accounts.account_id;

CREATE TABLE core.bonus_slabs
(
	bonus_slab_id 				SERIAL NOT NULL PRIMARY KEY,
	bonus_slab_code 			national character varying(12) NOT NULL,
	bonus_slab_name 			national character varying(50) NOT NULL,
	checking_frequency_id 			integer NOT NULL REFERENCES core.frequencies(frequency_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX bonus_slabs_bonus_slab_code_uix
ON core.bonus_slabs(UPPER(bonus_slab_code));


CREATE UNIQUE INDEX bonus_slabs_bonus_slab_name_uix
ON core.bonus_slabs(UPPER(bonus_slab_name));


CREATE VIEW core.bonus_slab_view
AS
SELECT
	bonus_slab_id,
	bonus_slab_code,
	bonus_slab_name,
	checking_frequency_id,
	frequency_name
FROM
core.bonus_slabs, core.frequencies
WHERE
core.bonus_slabs.checking_frequency_id = core.frequencies.frequency_id;

CREATE TABLE core.bonus_slab_details
(
	bonus_slab_detail_id 			SERIAL NOT NULL PRIMARY KEY,
	bonus_slab_id 				integer NOT NULL REFERENCES core.bonus_slabs(bonus_slab_id),
	amount_from 				money_strict NOT NULL,
	amount_to 				money_strict NOT NULL,
	bonus_rate 				decimal_strict NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
						CONSTRAINT bonus_slab_details_amounts_chk CHECK(amount_to>amount_from)
);


CREATE VIEW core.bonus_slab_detail_view
AS
SELECT
	bonus_slab_detail_id,
	core.bonus_slab_details.bonus_slab_id,
	core.bonus_slabs.bonus_slab_name AS slab_name,
	amount_from,
	amount_to,
	bonus_rate
FROM
	core.bonus_slab_details,
	core.bonus_slabs
WHERE
	core.bonus_slab_details.bonus_slab_id = core.bonus_slabs.bonus_slab_id;

CREATE TABLE core.agent_bonus_setups
(
	agent_bonus_setup_id SERIAL NOT NULL PRIMARY KEY,
	agent_id integer NOT NULL REFERENCES core.agents(agent_id),
	bonus_slab_id integer NOT NULL REFERENCES core.bonus_slabs(bonus_slab_id)
);

CREATE UNIQUE INDEX agent_bonus_setups_uix
ON core.agent_bonus_setups(agent_id, bonus_slab_id);


CREATE VIEW core.agent_bonus_setup_view
AS
SELECT
	agent_bonus_setup_id,
	agent_name,
	bonus_slab_name
FROM
	core.agent_bonus_setups,
	core.agents,
	core.bonus_slabs
WHERE
	core.agent_bonus_setups.agent_id = core.agents.agent_id
AND
	core.agent_bonus_setups.bonus_slab_id = core.bonus_slabs.bonus_slab_id;

CREATE TABLE core.ageing_slabs
(
	ageing_slab_id SERIAL NOT NULL PRIMARY KEY,
	ageing_slab_name national character varying(24) NOT NULL,
	from_days integer NOT NULL,
	to_days integer NOT NULL CHECK(to_days > 0)
);

CREATE UNIQUE INDEX ageing_slabs_ageing_slab_name_uix
ON core.ageing_slabs(UPPER(ageing_slab_name));

INSERT INTO core.ageing_slabs(ageing_slab_name,from_days,to_days)
SELECT 'SLAB 1',0, 30 UNION ALL
SELECT 'SLAB 2',31, 60 UNION ALL
SELECT 'SLAB 3',61, 90 UNION ALL
SELECT 'SLAB 4',91, 365 UNION ALL
SELECT 'SLAB 5',366, 999999;


CREATE TABLE core.party_types
(
	party_type_id 				SERIAL NOT NULL PRIMARY KEY,
	party_type_code 			national character varying(12) NOT NULL, 
	party_type_name 			national character varying(50) NOT NULL,
	is_supplier 				boolean NOT NULL CONSTRAINT party_types_is_supplier_df DEFAULT(false),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

INSERT INTO core.party_types(party_type_code, party_type_name) SELECT 'A', 'Agent';
INSERT INTO core.party_types(party_type_code, party_type_name) SELECT 'C', 'Customer';
INSERT INTO core.party_types(party_type_code, party_type_name) SELECT 'D', 'Dealer';
INSERT INTO core.party_types(party_type_code, party_type_name, is_supplier) SELECT 'S', 'Supplier', true;

CREATE TABLE core.parties
(
	party_id BIGSERIAL			NOT NULL PRIMARY KEY,
	party_type_id				smallint NOT NULL REFERENCES core.party_types(party_type_id),
	party_code				national character varying(12) NULL,
	first_name				national character varying(50) NOT NULL,
	middle_name				national character varying(50) NULL,
	last_name				national character varying(50) NOT NULL,
	party_name				text NULL,
	date_of_birth				date NULL,
	address_line_1				national character varying(128) NULL,	
	address_line_2				national character varying(128) NULL,
	street 					national character varying(50) NULL,
	city 					national character varying(50) NULL,
	state 					national character varying(50) NULL,
	country 				national character varying(50) NULL,
	phone 					national character varying(24) NULL,
	fax 					national character varying(24) NULL,
	cell 					national character varying(24) NULL,
	email 					national character varying(128) NULL,
	url 					national character varying(50) NULL,
	pan_number 				national character varying(50) NULL,
	sst_number 				national character varying(50) NULL,
	cst_number 				national character varying(50) NULL,
	allow_credit 				boolean NULL,
	maximum_credit_period 			smallint NULL,
	maximum_credit_amount 			money_strict2 NULL,
	charge_interest 			boolean NULL,
	interest_rate 				decimal NULL,
	interest_compounding_frequency_id	smallint NULL REFERENCES core.frequencies(frequency_id),
	account_id 				integer NOT NULL REFERENCES core.accounts(account_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX parties_party_code_uix
ON core.parties(UPPER(party_code));

/*******************************************************************
	GET UNIQUE EIGHT-TO-TEN DIGIT CUSTOMER CODE
	TO IDENTIFY A PARTY.
	BASIC FORMULA:
		1. FIRST TWO LETTERS OF FIRST NAME
		2. FIRST LETTER OF MIDDLE NAME (IF AVAILABLE)
		3. FIRST TWO LETTERS OF LAST NAME
		4. CUSTOMER NUMBER
*******************************************************************/

CREATE OR REPLACE FUNCTION core.get_party_code
(
	text, --First Name
	text, --Middle Name
	text  --Last Name
)
RETURNS text AS
$$
	DECLARE _party_code TEXT;
BEGIN
	SELECT INTO 
		_party_code 
			party_code
	FROM
		core.parties
	WHERE
		party_code LIKE 
			UPPER(left($1,2) ||
			CASE
				WHEN $2 IS NULL or $2 = '' 
				THEN left($3,3)
			ELSE 
				left($2,1) || left($3,2)
			END 
			|| '%')
	ORDER BY party_code desc
	LIMIT 1;

	_party_code :=
					UPPER
					(
						left($1,2)||
						CASE
							WHEN $2 IS NULL or $2 = '' 
							THEN left($3,3)
						ELSE 
							left($2,1)||left($3,2)
						END
					) 
					|| '-' ||
					CASE
						WHEN _party_code IS NULL 
						THEN '0001'
					ELSE 
						to_char(CAST(right(_party_code,4) AS integer)+1,'FM0000')
					END;
	RETURN _party_code;
END;
$$
LANGUAGE 'plpgsql';


CREATE FUNCTION core.update_party_code()
RETURNS trigger
AS
$$
BEGIN
	UPDATE core.parties
	SET 
		party_code=core.get_party_code(NEW.first_name, NEW.middle_name, NEW.last_name)
	WHERE core.parties.party_id=NEW.party_id;
	
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_party_code
AFTER INSERT
ON core.parties
FOR EACH ROW EXECUTE PROCEDURE core.update_party_code();


CREATE FUNCTION core.get_party_type_id_by_party_code(text)
RETURNS smallint
AS
$$
BEGIN
	RETURN
	(
		SELECT
			party_type_id
		FROM
			core.parties
		WHERE 
			core.parties.party_code=$1
	);
END
$$
LANGUAGE plpgsql;


CREATE FUNCTION core.get_party_id_by_party_code(text)
RETURNS smallint
AS
$$
BEGIN
	RETURN
	(
		SELECT
			party_id
		FROM
			core.parties
		WHERE 
			core.parties.party_code=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE VIEW core.party_view
AS
SELECT
	core.parties.party_id,
	core.party_types.party_type_code || ' (' || core.party_types.party_type_name || ')' AS party_type,
	core.parties.party_code,
	core.parties.first_name,
	core.parties.middle_name,
	core.parties.last_name,
	core.parties.party_name,
	core.parties.address_line_1,
	core.parties.address_line_2,
	core.parties.street,
	core.parties.city,
	core.parties.state,
	core.parties.country,
	core.parties.allow_credit,
	core.parties.maximum_credit_period,
	core.parties.maximum_credit_amount,
	core.parties.charge_interest,
	core.parties.interest_rate,
	core.parties.pan_number,
	core.parties.sst_number,
	core.parties.cst_number,
	core.parties.phone,
	core.parties.fax,
	core.parties.cell,
	core.parties.email,
	core.parties.url
FROM
core.parties
INNER JOIN
core.party_types
ON core.parties.party_type_id = core.party_types.party_type_id;

CREATE FUNCTION core.is_supplier(int)
RETURNS boolean
AS
$$
BEGIN
	IF EXISTS
	(
		SELECT 1 FROM core.parties 
		INNER JOIN core.party_types 
		ON core.parties.party_type_id=core.party_types.party_type_id
		WHERE core.parties.party_id=$1
		AND core.party_types.is_supplier=true
	) THEN
		RETURN true;
	END IF;
	
	RETURN false;
END
$$
LANGUAGE plpgsql;

CREATE TABLE core.shipping_addresses
(
	shipping_address_id			BIGSERIAL NOT NULL PRIMARY KEY,
	shipping_address_code			national character varying(24) NOT NULL,
	party_id				bigint NOT NULL REFERENCES core.parties(party_id),
	address_line_1				national character varying(128) NULL,	
	address_line_2				national character varying(128) NULL,
	street					national character varying(128) NULL,
	city					national character varying(128) NOT NULL,
	state					national character varying(128) NOT NULL,
	country					national character varying(128) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX shipping_addresses_shipping_address_code_uix
ON core.shipping_addresses(UPPER(shipping_address_code), party_id);

CREATE FUNCTION core.get_shipping_address_id_by_shipping_address_code(text)
RETURNS smallint
AS
$$
BEGIN
	RETURN
	(
		SELECT
			shipping_address_id
		FROM
			core.shipping_addresses
		WHERE 
			core.shipping_addresses.shipping_address_code=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.update_shipping_address_code_trigger()
RETURNS TRIGGER
AS
$$
DECLARE _counter integer;
BEGIN
	IF TG_OP='INSERT' THEN

		SELECT COALESCE(MAX(shipping_address_code::integer), 0) + 1
		INTO _counter
		FROM core.shipping_addresses
		WHERE party_id=NEW.party_id;

		NEW.shipping_address_code := trim(to_char(_counter, '000'));
		
		RETURN NEW;
	END IF;
END
$$
LANGUAGE plpgsql;


CREATE TRIGGER update_shipping_address_code_trigger
BEFORE INSERT
ON core.shipping_addresses
FOR EACH ROW EXECUTE PROCEDURE core.update_shipping_address_code_trigger();

CREATE VIEW core.shipping_address_view
AS
SELECT
	core.shipping_addresses.shipping_address_id,
	core.shipping_addresses.shipping_address_code,
	core.shipping_addresses.party_id,
	core.parties.party_code || ' (' || core.parties.party_name || ')' AS party,
	core.shipping_addresses.address_line_1,
	core.shipping_addresses.address_line_2,
	core.shipping_addresses.street,
	core.shipping_addresses.city,
	core.shipping_addresses.state,
	core.shipping_addresses.country
FROM core.shipping_addresses
INNER JOIN core.parties
ON core.shipping_addresses.party_id=core.parties.party_id;

CREATE TABLE core.brands
(
	brand_id SERIAL NOT NULL PRIMARY KEY,
	brand_code national character varying(12) NOT NULL,
	brand_name national character varying(150) NOT NULL
);

CREATE UNIQUE INDEX brands_brand_code_uix
ON core.brands(UPPER(brand_code));

CREATE UNIQUE INDEX brands_brand_name_uix
ON core.brands(UPPER(brand_name));

INSERT INTO core.brands(brand_code, brand_name)
SELECT 'DEF', 'Default';


CREATE TABLE core.shippers
(
	shipper_id				BIGSERIAL NOT NULL PRIMARY KEY,
	shipper_code				national character varying(12) NULL,
	company_name				national character varying(128) NOT NULL,
	shipper_name				national character varying(150) NULL,
	address_line_1				national character varying(128) NULL,	
	address_line_2				national character varying(128) NULL,
	street					national character varying(50) NULL,
	city					national character varying(50) NULL,
	state 					national character varying(50) NULL,
	country 				national character varying(50) NULL,
	phone 					national character varying(50) NULL,
	fax 					national character varying(50) NULL,
	cell 					national character varying(50) NULL,
	email 					national character varying(128) NULL,
	url 					national character varying(50) NULL,
	contact_person 				national character varying(50) NULL,
	contact_address_line_1			national character varying(128) NULL,	
	contact_address_line_2			national character varying(128) NULL,
	contact_street 				national character varying(50) NULL,
	contact_city 				national character varying(50) NULL,
	contact_state 				national character varying(50) NULL,
	contact_country 			national character varying(50) NULL,
	contact_email 				national character varying(128) NULL,
	contact_phone 				national character varying(50) NULL,
	contact_cell 				national character varying(50) NULL,
	factory_address 			national character varying(250) NULL,
	pan_number 				national character varying(50) NULL,
	sst_number 				national character varying(50) NULL,
	cst_number 				national character varying(50) NULL,
	account_id 				integer NOT NULL REFERENCES core.accounts(account_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX shippers_shipper_code_uix
ON core.shippers(UPPER(shipper_code));


/*******************************************************************
	GET UNIQUE EIGHT-TO-TEN DIGIT shipper CODE
	TO IDENTIFY A shipper.
	BASIC FORMULA:
		1. FIRST TWO LETTERS OF FIRST NAME
		2. FIRST LETTER OF MIDDLE NAME (IF AVAILABLE)
		3. FIRST TWO LETTERS OF LAST NAME
		4. shipper NUMBER
*******************************************************************/

CREATE OR REPLACE FUNCTION core.get_shipper_code
(
	text --company name
)
RETURNS text AS
$$
	DECLARE __shipper_code TEXT;
BEGIN
	SELECT INTO 
		__shipper_code 
			shipper_code
	FROM
		core.shippers
	WHERE
		shipper_code LIKE 
			UPPER(left($1, 3) || '%')
	ORDER BY shipper_code desc
	LIMIT 1;

	__shipper_code :=
					UPPER
					(
						left($1,3)
					) 
					|| '-' ||
					CASE
						WHEN __shipper_code IS NULL 
						THEN '0001'
					ELSE 
						to_char(CAST(right(__shipper_code, 4) AS integer)+1,'FM0000')
					END;
	RETURN __shipper_code;
END;
$$
LANGUAGE 'plpgsql';

CREATE FUNCTION core.update_shipper_code()
RETURNS trigger
AS
$$
BEGIN
	UPDATE core.shippers
	SET 
		shipper_code=core.get_shipper_code(NEW.company_name)
	WHERE core.shippers.shipper_id=NEW.shipper_id;
	
	RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_shipper_code
AFTER INSERT
ON core.shippers
FOR EACH ROW EXECUTE PROCEDURE core.update_shipper_code();


CREATE FUNCTION core.get_account_id_by_shipper_id(integer)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT
			core.shippers.account_id
		FROM
			core.shippers
		WHERE
			core.shippers.shipper_id=$1
	);
END
$$
LANGUAGE plpgsql;


CREATE TABLE core.tax_types
(
	tax_type_id 				SERIAL  NOT NULL PRIMARY KEY,
	tax_type_code 				national character varying(12) NOT NULL,
	tax_type_name 				national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX tax_types_tax_type_code_uix
ON core.tax_types(UPPER(tax_type_code));

CREATE UNIQUE INDEX tax_types_tax_type_name_uix
ON core.tax_types(UPPER(tax_type_name));

INSERT INTO core.tax_types(tax_type_code, tax_type_name)
SELECT 'DEF', 'Default';

CREATE TABLE core.taxes
(
	tax_id SERIAL  				NOT NULL PRIMARY KEY,
	tax_type_id 				smallint NOT NULL REFERENCES core.tax_types(tax_type_id),
	tax_code 				national character varying(12) NOT NULL,
	tax_name 				national character varying(50) NOT NULL,
	rate 					decimal NOT NULL,
	account_id 				integer NOT NULL REFERENCES core.accounts(account_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);



CREATE UNIQUE INDEX taxes_tax_code_uix
ON core.taxes(UPPER(tax_code));

CREATE UNIQUE INDEX taxes_tax_name_uix
ON core.taxes(UPPER(tax_name));

INSERT INTO core.taxes(tax_type_id, tax_code, tax_name, rate, account_id)
SELECT 1, 'VAT', 'Value Added Tax', 13, (SELECT account_id FROM core.accounts WHERE account_name='Sales Tax Payable') UNION ALL
SELECT 1, 'SAT', 'Sales Tax', 5, (SELECT account_id FROM core.accounts WHERE account_name='Sales Tax Payable');

CREATE VIEW core.tax_view
AS
SELECT
	tax_id,
	tax_code,
	tax_name,
	rate,
	tax_type_code,
	tax_type_name,
	account_code,
	account_name
FROM
	core.taxes,
	core.accounts,
	core.tax_types
WHERE
	core.taxes.account_id = core.accounts.account_id
AND
	core.taxes.tax_type_id = core.tax_types.tax_type_id;

CREATE TABLE core.item_groups
(
	item_group_id 				SERIAL NOT NULL PRIMARY KEY,
	item_group_code 			national character varying(12) NOT NULL,
	item_group_name 			national character varying(50) NOT NULL,
	exclude_from_purchase 			boolean NOT NULL CONSTRAINT item_groups_exclude_from_purchase_df DEFAULT('No'),
	exclude_from_sales 			boolean NOT NULL CONSTRAINT item_groups_exclude_from_sales_df DEFAULT('No'),
	tax_id 					smallint NOT NULL REFERENCES core.taxes(tax_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX item_groups_item_group_code_uix
ON core.item_groups(UPPER(item_group_code));

CREATE UNIQUE INDEX item_groups_item_group_name_uix
ON core.item_groups(UPPER(item_group_name));

INSERT INTO core.item_groups(item_group_code, item_group_name, tax_id)
SELECT 'DEF', 'Default', 1;


CREATE TABLE core.items
(
	item_id 				SERIAL NOT NULL PRIMARY KEY,
	item_code 				national character varying(12) NOT NULL,
	item_name 				national character varying(150) NOT NULL,
	item_group_id 				integer NOT NULL REFERENCES core.item_groups(item_group_id),
	brand_id 				integer NOT NULL REFERENCES core.brands(brand_id),
	preferred_supplier_id 			integer NULL REFERENCES core.parties(party_id) 
						CONSTRAINT items_preferred_supplier_id_chk CHECK(core.is_supplier(preferred_supplier_id) = true),
	lead_time_in_days 			integer NOT NULL DEFAULT(0),
	unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	hot_item 				boolean NOT NULL,
	cost_price 				money_strict NOT NULL,
	cost_price_includes_tax 		boolean NOT NULL CONSTRAINT items_cost_price_includes_tax_df DEFAULT('No'),
	selling_price 				money_strict NOT NULL,
	selling_price_includes_tax 		boolean NOT NULL CONSTRAINT items_selling_price_includes_tax_df DEFAULT('No'),
	tax_id 					integer NOT NULL REFERENCES core.taxes(tax_id),
	reorder_level 				integer NOT NULL,
	item_image 				image_path NULL,
	maintain_stock 				boolean NOT NULL DEFAULT(true),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX items_item_name_uix
ON core.items(UPPER(item_name));

CREATE FUNCTION core.get_item_id_by_item_code(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT
			item_id
		FROM
			core.items
		WHERE 
			core.items.item_code=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.get_item_tax_rate(integer)
RETURNS decimal
AS
$$
BEGIN
	RETURN
	COALESCE((
		SELECT core.taxes.rate
		FROM core.taxes
		INNER JOIN core.items
		ON core.taxes.tax_id = core.items.tax_id
		WHERE core.items.item_id=$1
	), 0);
END
$$
LANGUAGE plpgsql;

--TODO
CREATE VIEW core.item_view
AS
SELECT * FROM core.items;


/*******************************************************************
	PLEASE NOTE :

	THESE ARE THE MOST EFFECTIVE STOCK ITEM PRICES.
	THE PRICE IN THIS CATALOG IS ACTUALLY
	PICKED UP AT THE TIME OF PURCHASE AND SALES.

	A STOCK ITEM PRICE MAY BE DIFFERENT FOR DIFFERENT units.
	FURTHER, A STOCK ITEM WOULD BE SOLD AT A HIGHER PRICE
	WHEN SOLD LOOSE THAN WHAT IT WOULD ACTUALLY COST IN A
	COMPOUND UNIT.

	EXAMPLE, ONE CARTOON (20 BOTTLES) OF BEER BOUGHT AS A UNIT
	WOULD COST 25% LESS FROM THE SAME STORE.

*******************************************************************/

CREATE TABLE core.item_selling_prices
(	
	item_selling_price_id			BIGSERIAL NOT NULL PRIMARY KEY,
	item_id 				integer NOT NULL REFERENCES core.items(item_id),
	unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	party_type_id 				smallint NULL REFERENCES core.party_types(party_type_id), 
	price_type_id 				smallint NULL REFERENCES core.price_types(price_type_id),
	includes_tax 				boolean NOT NULL CONSTRAINT item_selling_prices_includes_tax_df DEFAULT('No'),
	price 					money_strict NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE VIEW core.item_selling_price_view
AS
SELECT
	core.item_selling_prices.item_selling_price_id,
	core.items.item_code,
	core.items.item_name,
	core.party_types.party_type_code,
	core.party_types.party_type_name,
	price
FROM
	core.item_selling_prices
INNER JOIN 	core.items
ON 
	core.item_selling_prices.item_id = core.items.item_id
LEFT JOIN
	core.price_types
ON
	core.item_selling_prices.price_type_id = core.price_types.price_type_id
LEFT JOIN
	core.party_types
ON	core.item_selling_prices.party_type_id = core.party_types.party_type_id;



CREATE TABLE core.item_cost_prices
(	
	item_cost_price_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	item_id 				integer NOT NULL REFERENCES core.items(item_id),
	entry_ts 				TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(now()),
	unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	party_id 				bigint NULL REFERENCES core.parties(party_id),
	lead_time_in_days 			integer NOT NULL DEFAULT(0),
	includes_tax 				boolean NOT NULL CONSTRAINT item_cost_prices_includes_tax_df DEFAULT('No'),
	price 					money_strict NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE VIEW core.item_cost_price_view
AS
SELECT
	core.item_cost_prices.item_cost_price_id,
	core.items.item_code,
	core.items.item_name,
	core.parties.party_code,
	core.parties.party_name,
	core.item_cost_prices.price
FROM 
core.item_cost_prices
INNER JOIN
core.items
ON core.item_cost_prices.item_id = core.items.item_id
LEFT JOIN
core.parties
ON core.item_cost_prices.party_id = core.parties.party_id;

CREATE FUNCTION core.get_item_cost_price(item_id_ integer, unit_id_ integer, party_id_ bigint)
RETURNS money
AS
$$
	DECLARE _price money;
	DECLARE _unit_id integer;
	DECLARE _factor decimal;
	DECLARE _tax_rate decimal;
	DECLARE _includes_tax boolean;
	DECLARE _tax money;
BEGIN
	--Fist pick the catalog price which matches all these fields:
	--Item, Unit, and Supplier.
	--This is the most effective price.
	SELECT 
		item_cost_prices.price, 
		item_cost_prices.unit_id,
		item_cost_prices.includes_tax
	INTO 
		_price, 
		_unit_id,
		_includes_tax		
	FROM core.item_cost_prices
	WHERE item_cost_prices.item_id = $1
	AND item_cost_prices.unit_id = $2
	AND item_cost_prices.party_id =$3;

	IF(_unit_id IS NULL) THEN
		--We do not have a cost price of this item for the unit supplied.
		--Let's see if this item has a price for other units.
		SELECT 
			item_cost_prices.price, 
			item_cost_prices.unit_id,
			item_cost_prices.includes_tax
		INTO 
			_price, 
			_unit_id,
			_includes_tax
		FROM core.item_cost_prices
		WHERE item_cost_prices.item_id=$1
		AND item_cost_prices.party_id =$3;
	END IF;

	
	IF(_price IS NULL) THEN
		--This item does not have cost price defined in the catalog.
		--Therefore, getting the default cost price from the item definition.
		SELECT 
			cost_price, 
			unit_id,
			cost_price_includes_tax
		INTO 
			_price, 
			_unit_id,
			_includes_tax
		FROM core.items
		WHERE core.items.item_id = $1;
	END IF;

	IF(_includes_tax) THEN
		_tax_rate := core.get_item_tax_rate($1);
		_price := _price / ((100 + _tax_rate)/ 100);
	END IF;

	--Get the unitary conversion factor if the requested unit does not match with the price defition.
	_factor := core.convert_unit($2, _unit_id);

	RETURN _price * _factor;
END
$$
LANGUAGE plpgsql;


CREATE TABLE office.store_types
(
	store_type_id 				SERIAL NOT NULL PRIMARY KEY,
	store_type_code 			national character varying(12) NOT NULL,
	store_type_name 			national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX store_types_Code_uix
ON office.store_types(UPPER(store_type_code));


CREATE UNIQUE INDEX store_types_Name_uix
ON office.store_types(UPPER(store_type_name));

INSERT INTO office.store_types(store_type_code,store_type_name)
SELECT 'GOD', 'Godown' UNION ALL
SELECT 'SAL', 'Sales Center' UNION ALL
SELECT 'WAR', 'Warehouse' UNION ALL
SELECT 'PRO', 'Production';


CREATE TABLE office.stores
(
	store_id SERIAL 			NOT NULL PRIMARY KEY,
	office_id 				integer NOT NULL REFERENCES office.offices(office_id),
	store_code 				national character varying(12) NOT NULL,
	store_name 				national character varying(50) NOT NULL,
	address 				national character varying(50) NULL,
	store_type_id 				integer NOT NULL REFERENCES office.store_types(store_type_id),
	allow_sales 				boolean NOT NULL DEFAULT(true),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX stores_store_code_uix
ON office.stores(UPPER(store_code));

CREATE UNIQUE INDEX stores_store_name_uix
ON office.stores(UPPER(store_name));


--TODO
CREATE VIEW office.store_view
AS
SELECT * FROM office.stores;


CREATE TABLE office.cash_repositories
(
	cash_repository_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	office_id 				integer NOT NULL REFERENCES office.offices(office_id),
	cash_repository_code 			national character varying(12) NOT NULL,
	cash_repository_name 			national character varying(50) NOT NULL,
	parent_cash_repository_id 		integer NULL REFERENCES office.cash_repositories(cash_repository_id),
	description 				national character varying(100) NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX cash_repositories_cash_repository_code_uix
ON office.cash_repositories(UPPER(cash_repository_code));

CREATE UNIQUE INDEX cash_repositories_cash_repository_name_uix
ON office.cash_repositories(UPPER(cash_repository_name));

CREATE FUNCTION office.get_cash_repository_id_by_cash_repository_code(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT cash_repository_id
		FROM office.cash_repositories
		WHERE cash_repository_code=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION office.get_cash_repository_id_by_cash_repository_name(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT cash_repository_id
		FROM office.cash_repositories
		WHERE cash_repository_name=$1
	);
END
$$
LANGUAGE plpgsql;



CREATE VIEW office.cash_repository_view
AS
SELECT
	office.cash_repositories.cash_repository_id,
	office.cash_repositories.cash_repository_code,
	office.cash_repositories.cash_repository_name,
	parent_cash_repositories.cash_repository_code parent_cr_code,
	parent_cash_repositories.cash_repository_name parent_cr_name,
	office.cash_repositories.description
FROM
	office.cash_repositories
LEFT OUTER JOIN
	office.cash_repositories AS parent_cash_repositories
ON
	office.cash_repositories.parent_cash_repository_id=parent_cash_repositories.cash_repository_id;
 
CREATE TABLE office.counters
(
	counter_id 				SERIAL NOT NULL PRIMARY KEY,
	store_id 				smallint NOT NULL REFERENCES office.stores(store_id),
	cash_repository_id 			integer NOT NULL REFERENCES office.cash_repositories(cash_repository_id),
	counter_code 				national character varying(12) NOT NULL,
	counter_name 				national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX counters_counter_code_uix
ON office.counters(UPPER(counter_code));

CREATE UNIQUE INDEX counters_counter_name_uix
ON office.counters(UPPER(counter_name));


CREATE TABLE office.cost_centers
(
	cost_center_id 				SERIAL NOT NULL PRIMARY KEY,
	cost_center_code 			national character varying(24) NOT NULL,
	cost_center_name 			national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX cost_centers_cost_center_code_uix
ON office.cost_centers(UPPER(cost_center_code));

CREATE UNIQUE INDEX cost_centers_cost_center_name_uix
ON office.cost_centers(UPPER(cost_center_name));

INSERT INTO office.cost_centers(cost_center_code, cost_center_name)
SELECT 'DEF', 'Default' UNION ALL
SELECT 'GEN', 'General Administration' UNION ALL
SELECT 'HUM', 'Human Resources' UNION ALL
SELECT 'SCC', 'Support & Customer Care' UNION ALL
SELECT 'GAE', 'Guest Accomodation & Entertainment' UNION ALL
SELECT 'MKT', 'Marketing & Promotion' UNION ALL
SELECT 'SAL', 'Sales & Billing' UNION ALL
SELECT 'FIN', 'Finance & Accounting';

CREATE VIEW office.cost_center_view
AS
SELECT
	office.cost_centers.cost_center_id,
	office.cost_centers.cost_center_code,
	office.cost_centers.cost_center_name
FROM
	office.cost_centers;


CREATE TABLE office.cashiers
(
	cashier_id BIGSERIAL NOT NULL PRIMARY KEY,
	counter_id integer NOT NULL REFERENCES office.counters(counter_id),
	user_id integer NOT NULL REFERENCES office.users(user_id),
	assigned_by_user_id integer NOT NULL REFERENCES office.users(user_id),
	transaction_date date NOT NULL,
	closed boolean NOT NULL
);

CREATE UNIQUE INDEX Cashiers_user_id_TDate_uix
ON office.cashiers(user_id ASC, transaction_date DESC);


/*******************************************************************
	STORE policy DEFINES THE RIGHT OF USERS TO ACCESS A STORE.
	AN ADMINISTRATOR CAN ACCESS ALL THE stores, BY DEFAULT.
*******************************************************************/


CREATE TABLE policy.store_policies
(
	store_policy_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	written_by_user_id 			integer NOT NULL REFERENCES office.users(user_id),
	status 					boolean NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE TABLE policy.store_policy_details
(
	store_policy_detail_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	store_policy_id 			integer NOT NULL REFERENCES policy.store_policies(store_policy_id),
	user_id 				integer NOT NULL REFERENCES office.users(user_id),
	store_id 				smallint NOT NULL REFERENCES office.stores(store_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE TABLE core.item_opening_inventory
(
	item_opening_inventory_id 		BIGSERIAL NOT NULL PRIMARY KEY,
	entry_ts 				TIMESTAMP WITH TIME ZONE NOT NULL,
	item_id 				integer NOT NULL REFERENCES core.items(item_id),
	store_id 				smallint NOT NULL REFERENCES office.stores(store_id),
	unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	quantity 				integer NOT NULL,
	amount 					money_strict NOT NULL,
	base_unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	base_quantity 				decimal NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE TABLE audit.history
(
	activity_id				BIGSERIAL NOT NULL PRIMARY KEY,
	event_ts 				TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(NOW()),
	principal_user 				national character varying(50) NOT NULL DEFAULT(current_user),
	user_id 				integer /*NOT*/ NULL REFERENCES office.users(user_id),
	type 					national character varying(50) NOT NULL,
	table_schema 				national character varying(50) NOT NULL,
	table_name 				national character varying(50) NOT NULL,
	primary_key_id 				national character varying(50) NOT NULL,
	column_name 				national character varying(50) NOT NULL,
	old_val 				text NULL,
	new_val 				text NULL,
						CONSTRAINT audit_history_val_chk 
							CHECK
							(
									(old_val IS NULL AND new_val IS NOT NULL) OR
									(old_val IS NOT NULL AND new_val IS NULL) OR
									(old_val IS NOT NULL AND new_val IS NOT NULL)
							)
);


CREATE FUNCTION office.is_sys_user(integer)
RETURNS boolean
AS
$$
BEGIN
	IF EXISTS
	(
		SELECT * FROM office.users
		WHERE user_id=$1
		AND role_id IN
		(
			SELECT office.roles.role_id FROM office.roles WHERE office.roles.role_code='SYST'
		)
	) THEN
		RETURN true;
	END IF;

	RETURN false;
END
$$
LANGUAGE plpgsql;


/*******************************************************************
	THIS FUNCTION RETURNS A NEW INCREMENTAL COUNTER SUBJECT 
	TO BE USED TO GENERATE TRANSACTION CODES
*******************************************************************/

CREATE FUNCTION transactions.get_new_transaction_counter(date)
RETURNS integer
AS
$$
	DECLARE _ret_val integer;
BEGIN
	SELECT INTO _ret_val
		COALESCE(MAX(transaction_counter),0)
	FROM transactions.transaction_master
	WHERE value_date=$1;

	IF _ret_val IS NULL THEN
		RETURN 1::integer;
	ELSE
		RETURN (_ret_val + 1)::integer;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE FUNCTION transactions.get_transaction_code(value_date date, office_id integer, user_id integer, login_id bigint)
RETURNS text
AS
$$
	DECLARE _office_id bigint:=$2;
	DECLARE _user_id integer:=$3;
	DECLARE _login_id bigint:=$4;
	DECLARE _ret_val text;	
BEGIN
	_ret_val:= transactions.get_new_transaction_counter($1)::text || '-' || TO_CHAR($1, 'YYYY-MM-DD') || '-' || CAST(_office_id as text) || '-' || CAST(_user_id as text) || '-' || CAST(_login_id as text)   || '-' ||  TO_CHAR(now(), 'HH24-MI-SS');
	RETURN _ret_val;
END
$$
LANGUAGE plpgsql;


CREATE TABLE transactions.transaction_master
(
	transaction_master_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	transaction_counter 			integer NOT NULL, --Sequence of transactions of a date
	transaction_code 			national character varying(50) NOT NULL,
	book 					national character varying(50) NOT NULL, --Transaction book. Ex. Sales, Purchase, Journal
	value_date 				date NOT NULL,
	transaction_ts 				TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(now()),
	login_id 				bigint NOT NULL REFERENCES audit.logins(login_id),
	user_id 				integer NOT NULL REFERENCES office.users(user_id),
	sys_user_id 				integer NULL REFERENCES office.users(user_id)
						CONSTRAINT transaction_master_sys_user_id_chk CHECK(sys_user_id IS NULL OR office.is_sys_user(sys_user_id)=true),
	office_id 				integer NOT NULL REFERENCES office.offices(office_id),
	cost_center_id 				integer NULL REFERENCES office.cost_centers(cost_center_id),
	reference_number 			national character varying(24) NULL,
	statement_reference			text NULL,
	last_verified_on 			TIMESTAMP WITH TIME ZONE NULL, 
	verified_by_user_id 			integer NULL REFERENCES office.users(user_id),
	verification_status_id 			smallint NOT NULL REFERENCES core.verification_statuses(verification_status_id) DEFAULT(0/*Awaiting verification*/),
	verification_reason 			national character varying(128) NOT NULL CONSTRAINT transaction_master_verification_reason_df DEFAULT(''),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW()),
						CONSTRAINT transaction_master_login_id_sys_user_id_chk
							CHECK
							(
								(
									login_id IS NULL AND sys_user_id IS NOT NULL
								)

								OR

								(
									login_id IS NOT NULL AND sys_user_id IS NULL
								)
							)
);

CREATE UNIQUE INDEX transaction_master_transaction_code_uix
ON transactions.transaction_master(UPPER(transaction_code));



CREATE TABLE transactions.transaction_details
(
	transaction_detail_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	transaction_master_id 			bigint NOT NULL REFERENCES transactions.transaction_master(transaction_master_id),
	tran_type 				transaction_type NOT NULL,
	account_id 				integer NOT NULL REFERENCES core.accounts(account_id),
	statement_reference 			text NULL,
	cash_repository_id 			integer NULL REFERENCES office.cash_repositories(cash_repository_id),
	amount 					money_strict NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE TABLE transactions.stock_master
(
	stock_master_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	transaction_master_id 			bigint NOT NULL REFERENCES transactions.transaction_master(transaction_master_id),
	party_id 				bigint NULL REFERENCES core.parties(party_id),
	agent_id 				integer NULL REFERENCES core.agents(agent_id),
	price_type_id 				integer NULL REFERENCES core.price_types(price_type_id),
	is_credit 				boolean NOT NULL CONSTRAINT stock_master_is_credit_df DEFAULT(false),
	shipper_id 				integer NULL REFERENCES core.shippers(shipper_id),
	shipping_address_id 			integer NULL REFERENCES core.shipping_addresses(shipping_address_id),
	shipping_charge 			money NOT NULL CONSTRAINT stock_master_shipping_charge_df DEFAULT(0),
	store_id 				integer NULL REFERENCES office.stores(store_id),
	cash_repository_id 			integer NULL REFERENCES office.cash_repositories(cash_repository_id),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE TABLE transactions.stock_details
(
	stock_master_detail_id 			BIGSERIAL NOT NULL PRIMARY KEY,
	stock_master_id 			bigint NOT NULL REFERENCES transactions.stock_master(stock_master_id),
	tran_type 				transaction_type NOT NULL,
	store_id 				integer NULL REFERENCES office.stores(store_id),
	item_id 				integer NOT NULL REFERENCES core.items(item_id),
	quantity 				integer NOT NULL,
	unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	base_quantity 				decimal NOT NULL,
	base_unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	price 					money_strict NOT NULL,
	discount money 				NOT NULL CONSTRAINT stock_details_discount_df DEFAULT(0),
	tax_rate 				decimal NOT NULL CONSTRAINT stock_details_tax_rate_df DEFAULT(0),
	tax money 				NOT NULL CONSTRAINT stock_details_tax_df DEFAULT(0),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE MATERIALIZED VIEW transactions.trial_balance_view
AS
SELECT core.get_account_name(account_id), 
	SUM(CASE transactions.transaction_details.tran_type WHEN 'Dr' THEN amount ELSE NULL END) AS debit,
	SUM(CASE transactions.transaction_details.tran_type WHEN 'Cr' THEN amount ELSE NULL END) AS Credit
FROM transactions.transaction_details
GROUP BY account_id;


--TODO
CREATE TABLE transactions.non_gl_stock_master
(
	non_gl_stock_master_id			BIGSERIAL NOT NULL PRIMARY KEY,
	value_date 				date NOT NULL,
	book					national character varying(48) NOT NULL,
	party_id 				bigint NULL REFERENCES core.parties(party_id),
	price_type_id 				integer NULL REFERENCES core.price_types(price_type_id),
	transaction_ts 				TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT(now()),
	login_id 				bigint NOT NULL REFERENCES audit.logins(login_id),
	user_id 				integer NOT NULL REFERENCES office.users(user_id),
	office_id 				integer NOT NULL REFERENCES office.offices(office_id),
	reference_number			national character varying(24) NULL,
	statement_reference 			text NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE TABLE transactions.non_gl_stock_details
(
	non_gl_stock_details_id 		BIGSERIAL NOT NULL PRIMARY KEY,
	non_gl_stock_master_id 			bigint NOT NULL REFERENCES transactions.non_gl_stock_master(non_gl_stock_master_id),
	item_id 				integer NOT NULL REFERENCES core.items(item_id),
	quantity 				integer NOT NULL,
	unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	base_quantity 				decimal NOT NULL,
	base_unit_id 				integer NOT NULL REFERENCES core.units(unit_id),
	price 					money_strict NOT NULL,
	discount 				money NOT NULL CONSTRAINT non_gl_stock_details_discount_df DEFAULT(0),
	tax_rate 				decimal NOT NULL CONSTRAINT non_gl_stock_details_tax_rate_df DEFAULT(0),
	tax 					money NOT NULL CONSTRAINT non_gl_stock_details_tax_df DEFAULT(0),
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE TABLE crm.lead_sources
(
	lead_source_id				SERIAL NOT NULL PRIMARY KEY,
	lead_source_code 			national character varying(12) NOT NULL,
	lead_source_name 			national character varying(128) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX lead_sources_lead_source_code_uix
ON crm.lead_sources(UPPER(lead_source_code));


CREATE UNIQUE INDEX lead_sources_lead_source_name_uix
ON crm.lead_sources(UPPER(lead_source_name));

INSERT INTO crm.lead_sources(lead_source_code, lead_source_name)
SELECT 'AG', 'Agent' UNION ALL
SELECT 'CC', 'Cold Call' UNION ALL
SELECT 'CR', 'Customer Reference' UNION ALL
SELECT 'DI', 'Direct Inquiry' UNION ALL
SELECT 'EV', 'Events' UNION ALL
SELECT 'PR', 'Partner';

CREATE TABLE crm.lead_statuses
(
	lead_status_id				SERIAL NOT NULL PRIMARY KEY,
	lead_status_code 			national character varying(12) NOT NULL,
	lead_status_name 			national character varying(128) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX lead_statuses_lead_status_code_uix
ON crm.lead_statuses(UPPER(lead_status_code));


CREATE UNIQUE INDEX lead_statuses_lead_status_name_uix
ON crm.lead_statuses(UPPER(lead_status_name));

INSERT INTO crm.lead_statuses(lead_status_code, lead_status_name)
SELECT 'CL', 'Cool' UNION ALL
SELECT 'CF', 'Contact in Future' UNION ALL
SELECT 'LO', 'Lost' UNION ALL
SELECT 'IP', 'In Prgress' UNION ALL
SELECT 'QF', 'Qualified';

CREATE TABLE crm.opportunity_stages
(
	opportunity_stage_id 			SERIAL  NOT NULL PRIMARY KEY,
	opportunity_stage_code 			national character varying(12) NOT NULL,
	opportunity_stage_name 			national character varying(50) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX opportunity_stages_opportunity_stage_code_uix
ON crm.opportunity_stages(UPPER(opportunity_stage_code));

CREATE UNIQUE INDEX opportunity_stages_opportunity_stage_name_uix
ON crm.opportunity_stages(UPPER(opportunity_stage_name));


INSERT INTO crm.opportunity_stages(opportunity_stage_code, opportunity_stage_name)
SELECT 'PRO', 'Prospecting' UNION ALL
SELECT 'QUA', 'Qualification' UNION ALL
SELECT 'NEG', 'Negotiating' UNION ALL
SELECT 'VER', 'Verbal' UNION ALL
SELECT 'CLW', 'Closed Won' UNION ALL
SELECT 'CLL', 'Closed Lost';

CREATE FUNCTION transactions.get_invoice_amount(transaction_master_id_ bigint)
RETURNS money
AS
$$
DECLARE _shipping_charge money;
DECLARE _stock_total money;
BEGIN
	SELECT SUM((quantity * price) + tax - discount) INTO _stock_total
	FROM transactions.stock_details
	WHERE transactions.stock_details.stock_master_id =
	(
		SELECT transactions.stock_master.stock_master_id
		FROM transactions.stock_master WHERE transactions.stock_master.transaction_master_id= $1
	);

	SELECT shipping_charge INTO _shipping_charge
	FROM transactions.stock_master
	WHERE transactions.stock_master.transaction_master_id=$1;

	RETURN COALESCE(_stock_total + _shipping_charge, 0::money);	
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION core.count_item_in_stock(item_id_ integer, unit_id_ integer, store_id_ integer)
RETURNS decimal
AS
$$
	DECLARE _base_unit_id integer;
	DECLARE _debit decimal;
	DECLARE _credit decimal;
	DECLARE _balance decimal;
	DECLARE _factor decimal;
BEGIN

	--Get the base item unit
	SELECT 
		core.get_root_unit_id(core.items.unit_id) 
	INTO _base_unit_id
	FROM core.items
	WHERE core.items.item_id=$1;

	--Get the sum of debit stock quantity from approved transactions
	SELECT 
		COALESCE(SUM(base_quantity), 0)
	INTO _debit
	FROM transactions.stock_details
	INNER JOIN transactions.stock_master
	ON transactions.stock_master.stock_master_id = transactions.stock_details.stock_master_id
	INNER JOIN transactions.transaction_master
	ON transactions.stock_master.transaction_master_id = transactions.transaction_master.transaction_master_id
	WHERE transactions.transaction_master.verification_status_id > 0
	AND transactions.stock_details.item_id=$1
	AND transactions.stock_details.store_id=$3
	AND transactions.stock_details.tran_type='Dr';
	
	--Get the sum of credit stock quantity from approved transactions
	SELECT 
		COALESCE(SUM(base_quantity), 0)
	INTO _credit
	FROM transactions.stock_details
	INNER JOIN transactions.stock_master
	ON transactions.stock_master.stock_master_id = transactions.stock_details.stock_master_id
	INNER JOIN transactions.transaction_master
	ON transactions.stock_master.transaction_master_id = transactions.transaction_master.transaction_master_id
	WHERE transactions.transaction_master.verification_status_id > 0
	AND transactions.stock_details.item_id=$1
	AND transactions.stock_details.store_id=$3
	AND transactions.stock_details.tran_type='Cr';
	
	_balance:= _debit - _credit;

	
	_factor = core.convert_unit($2, _base_unit_id);

	return _balance / _factor;	
END
$$
LANGUAGE plpgsql;

CREATE TABLE core.switch_categories
(
	switch_category_id 			SERIAL NOT NULL PRIMARY KEY,
	switch_category_name			national character varying(128) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX switch_categories_switch_category_name_uix
ON core.switch_categories(UPPER(switch_category_name));

INSERT INTO core.switch_categories(switch_category_name)
SELECT 'General';

CREATE FUNCTION core.get_switch_category_id_by_name(text)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT switch_category_id
		FROM core.switch_categories
		WHERE core.switch_categories.switch_category_name=$1
	);
END
$$
LANGUAGE plpgsql;

CREATE TABLE office.work_centers
(
	work_center_id				SERIAL NOT NULL PRIMARY KEY,
	office_id				integer NOT NULL REFERENCES office.offices(office_id),
	work_center_code			national character varying(12) NOT NULL,
	work_center_name			national character varying(128) NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE UNIQUE INDEX work_centers_work_center_code_uix
ON office.work_centers(UPPER(work_center_code));

CREATE UNIQUE INDEX work_centers_work_center_name_uix
ON office.work_centers(UPPER(work_center_name));

CREATE VIEW office.work_center_view
AS
SELECT
	office.work_centers.work_center_id,
	office.offices.office_code || ' (' || office.offices.office_name || ')' AS office,
	office.work_centers.work_center_code,
	office.work_centers.work_center_name
FROM office.work_centers
INNER JOIN office.offices
ON office.work_centers.office_id = office.offices.office_id;



CREATE FUNCTION office.is_admin(integer)
RETURNS boolean
AS
$$
BEGIN
	RETURN
	(
		SELECT office.roles.is_admin FROM office.users
		INNER JOIN office.roles
		ON office.users.role_id = office.roles.role_id
		WHERE office.users.user_id=$1
	);
END
$$
LANGUAGE PLPGSQL;


CREATE FUNCTION office.is_sys(integer)
RETURNS boolean
AS
$$
BEGIN
	RETURN
	(
		SELECT office.roles.is_system FROM office.users
		INNER JOIN office.roles
		ON office.users.role_id = office.roles.role_id
		WHERE office.users.user_id=$1
	);
END
$$
LANGUAGE PLPGSQL;



CREATE TABLE policy.voucher_verification_policy
(
	user_id					integer NOT NULL PRIMARY KEY REFERENCES office.users(user_id),
	can_verify_sales_transactions		boolean NOT NULL CONSTRAINT voucher_verification_policy_verify_sales_df DEFAULT(false),
	sales_verification_limit		money NOT NULL CONSTRAINT voucher_verification_policy_sales_verification_limit_df DEFAULT(0),
	can_verify_purchase_transactions	boolean NOT NULL CONSTRAINT voucher_verification_policy_verify_purchase_df DEFAULT(false),
	purchase_verification_limit		money NOT NULL CONSTRAINT voucher_verification_policy_purchase_verification_limit_df DEFAULT(0),
	can_verify_gl_transactions		boolean NOT NULL CONSTRAINT voucher_verification_policy_verify_gl_df DEFAULT(false),
	gl_verification_limit			money NOT NULL CONSTRAINT voucher_verification_policy_gl_verification_limit_df DEFAULT(0),
	can_self_verify				boolean NOT NULL CONSTRAINT voucher_verification_policy_verify_self_df DEFAULT(false),
	self_verification_limit			money NOT NULL CONSTRAINT voucher_verification_policy_self_verification_limit_df DEFAULT(0),
	effective_from				date NOT NULL,
	ends_on					date NOT NULL,
	is_active				boolean NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE VIEW policy.voucher_verification_policy_view
AS
SELECT
	policy.voucher_verification_policy.user_id,
	office.users.user_name,
	policy.voucher_verification_policy.can_verify_sales_transactions,
	policy.voucher_verification_policy.sales_verification_limit,
	policy.voucher_verification_policy.can_verify_purchase_transactions,
	policy.voucher_verification_policy.purchase_verification_limit,
	policy.voucher_verification_policy.can_verify_gl_transactions,
	policy.voucher_verification_policy.gl_verification_limit,
	policy.voucher_verification_policy.can_self_verify,
	policy.voucher_verification_policy.self_verification_limit,
	policy.voucher_verification_policy.effective_from,
	policy.voucher_verification_policy.ends_on,
	policy.voucher_verification_policy.is_active
FROM policy.voucher_verification_policy
INNER JOIN office.users
ON policy.voucher_verification_policy.user_id=office.users.user_id;

CREATE TABLE policy.auto_verification_policy
(
	user_id					integer NOT NULL PRIMARY KEY REFERENCES office.users(user_id),
	verify_sales_transactions		boolean NOT NULL CONSTRAINT auto_verification_policy_verify_sales_df DEFAULT(false),
	sales_verification_limit		money NOT NULL CONSTRAINT auto_verification_policy_sales_verification_limit_df DEFAULT(0),
	verify_purchase_transactions		boolean NOT NULL CONSTRAINT auto_verification_policy_verify_purchase_df DEFAULT(false),
	purchase_verification_limit		money NOT NULL CONSTRAINT auto_verification_policy_purchase_verification_limit_df DEFAULT(0),
	verify_gl_transactions			boolean NOT NULL CONSTRAINT auto_verification_policy_verify_gl_df DEFAULT(false),
	gl_verification_limit			money NOT NULL CONSTRAINT auto_verification_policy_gl_verification_limit_df DEFAULT(0),
	effective_from				date NOT NULL,
	ends_on					date NOT NULL,
	is_active				boolean NOT NULL,
	audit_user_id				integer NULL REFERENCES office.users(user_id),
	audit_ts				TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);

CREATE VIEW policy.auto_verification_policy_view
AS
SELECT
	policy.auto_verification_policy.user_id,
	office.users.user_name,
	policy.auto_verification_policy.verify_sales_transactions,
	policy.auto_verification_policy.sales_verification_limit,
	policy.auto_verification_policy.verify_purchase_transactions,
	policy.auto_verification_policy.purchase_verification_limit,
	policy.auto_verification_policy.verify_gl_transactions,
	policy.auto_verification_policy.gl_verification_limit,
	policy.auto_verification_policy.effective_from,
	policy.auto_verification_policy.ends_on,
	policy.auto_verification_policy.is_active
FROM policy.auto_verification_policy
INNER JOIN office.users
ON policy.auto_verification_policy.user_id=office.users.user_id;
