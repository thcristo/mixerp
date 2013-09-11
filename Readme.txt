Hello there,

MixERP is a feature rich, easy to use, open source ERP solution which is still in alpha stage.

-------------------------------------------------------------------------------------------------------------------------------------------------
 Installing the database:
-------------------------------------------------------------------------------------------------------------------------------------------------

MixERP uses the powerful, award-winning, highly stable, and objected oriented database PostgreSQL. PostgreSQL server is an open source 
database server, which can be downloaded from: 

http://postgresql.org


Please run the following database scripts under the directory "/MixERP.Net.FrontEnd/db/en-US/", in this order:

1. mixerp.sql
2. mixerp-db-logic.sql
3. party-sample.sql (optional)
4. sample-data.sql  (optional)


**Please Note:**
If you are using PostgreSQL 9.2 and below, you would have to make a very minor change to 
the SQL script "customer-sample.sql":

1. Find the word 'MATERIALIZED VIEW' and replace that with 'VIEW'.
2. Comment out all the lines starting with 'REFRESH MATERIALIZED VIEW'.


-------------------------------------------------------------------------------------------------------------------------------------------------
Non English Speaking Countries:
-------------------------------------------------------------------------------------------------------------------------------------------------
MixERP is a multilingual product by design. Instead of hardcoding everying, we maintain a central resource file respository 
on the directory "MixERP.Net.FrontEnd/App_GlobalResources".

Please find the following files:

Titles.resx
-Titles and only titles should be stored in this file, complying to the rules of capitalization.
-Resource keys: use ProperCasing.

Questions.resx
-Questions are stored in this file.
-Resource keys: ProperCasing.

Labels.resx
-Field labels are stored here. Must be a complete sentence or meaningful phrase.
-Resource keys: use ProperCasing.

Warnings.resx
-Application warnings are stored here. Must be a complete sentence or meaningful phrase.
-Resource keys: use ProperCasing.

Setup.resx
-System resource.
-Resource keys: use ProperCasing.


FormResource.resx
-PostgreSQL columns are stored as resource keys. These are used on dynamically generated forms and reports. 
-Resource keys: use lowercase_underscore_separator.

-------------------------------------------------------------------------------------------------------------------------------------------------


Watch out for more ...

MixERP team.