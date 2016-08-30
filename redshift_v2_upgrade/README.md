## Redshift v2 Migrator

This script backs up pre-v2 Redshift data stored by Stitch into a
v2-compatible format. This script must be run before dropping the 
`_rjm` schema when upgrading. Running this script for the 
schema `my_schema` containing Stitch-generated views `my_data1` and
`my_data2` will result in two new tables in `my_schema` called 
`_sdc_backup_my_data1` and `_sdc_backup_my_data2`.

### usage

```bash
PGPASSWORD=mypass DRY_RUN=true bash migrate.sh --user my-stitch-user --host mydb.abcdef1234.us-east-1.redshift.amazonaws.com --port 5439 --database mydb --schema my_schema
```

The database user must have full permission on `my_schema` and read access to the `_rjm` schema.  We suggest using the same user that Stitch uses to populate your database.

Depends on `bash`, `psql` and `awk`

### compatibility

Tested on OS X 10.11.5 and Ubuntu 14.04.5
