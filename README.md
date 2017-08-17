# mysql-db-version-control
Useful procedures and table for running own DB version control in MySQL

## Usage

In order to use this scheme, just apply the `init.sql` file to your database. This will create `dbversion` table where all versions will be stored.

Then you can use procedures to keep linking your version with your favourite Jira/Github, etc

```mysql
# DB version
SET @version := db_version_increment('PATCH');

# Some additional SQL patches

INSERT INTO dbversion (dbv_name, dbv_description) VALUES (@version, 'Changes according to the issue #1');
```

To deprecate column or table in your database just use in your patch `deprecate_table(table_name)` or `deprecate_column(table_name, column_name)`
