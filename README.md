# train-reservation
## Create users, tables, grants, initial data
1. (ADMIN) Run Create_Users.sql to create users and assign roles
2. (CRS_ADMIN) Run DDL.sql to create schema tables
3. (CRS_ADMIN) Run Grant_Permissions.sql to allow roles access to certain tables
4. (CRS_DATA) Run DML.sql to fill all tables with initial data
5. (CRS_ADMIN) Open Create_Packages.sql and run to create all packages