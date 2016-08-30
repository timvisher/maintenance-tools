#!/bin/bash

###
# stitch v2 redshift migrator
#
# Migrates Stitch data in Redshift to a v2-compatible structure.
# This script is provided as-is and should be used with caution.
#
# Usage: PGPASSWORD=mypass DRY_RUN=true bash migrate.sh --user my-stitch-user --host mydb.abcdef1234.us-east-1.redshift.amazonaws.com --port 5439 --database mydb --schema my_schema
#
# The above will print the backup commands the script
# would run, set DRY_RUN=false to actually run them.
#
##

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -h|--host)
    HOST="$2"
    shift # past argument
    ;;
    -p|--port)
    PORT="$2"
    shift # past argument
    ;;
    -u|--user)
    USER="$2"
    shift # past argument
    ;;
    -d|--database)
    DATABASE="$2"
    shift # past argument
    ;;
    -s|--schema)
    SCHEMA="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

SQL_CMD="psql --host $HOST --port $PORT --user $USER $DATABASE --no-align --quiet -t --field-separator ' '"
TMP_FILE=".sdc.tmp"
TMP_SQL_FILE=".sdc.sql.tmp"

backup_table ()
{
	TABLE=$1
	SOURCE_SCHEMA=($(awk "\$2 == \"$TABLE\" {print \$3; exit;}" $TMP_FILE))
	SOURCE_TABLE=($(awk "\$2 == \"$TABLE\" {print \$4; exit;}" $TMP_FILE))
	TABLE_VERSION=$(echo $SOURCE_TABLE | grep -Eo '[0-9]+$')
	FIELDS=$(awk -f migrate.awk -v "table=$TABLE" -v "table_version=$TABLE_VERSION" $TMP_FILE)
	printf "create table \"%s\".\"_sdc_backup_%s\" as select %s from \"%s\".\"%s\";\n" \
		   "$SCHEMA" \
		   "$TABLE" \
		   "$FIELDS" \
		   "$SOURCE_SCHEMA" \
		   "$SOURCE_TABLE" > "${TMP_SQL_FILE}"

	if [ "$DRY_RUN" = true ]; then
		echo ""
		cat "$TMP_SQL_FILE"
	else
		eval "${SQL_CMD} -f ${TMP_SQL_FILE}"
	fi

}

COLUMN_SQL="
select
    dep.view_schema
  , dep.view_name
  , dep.table_schema
  , dep.table_name
	, cols.column_name
	, cols.data_type
from information_schema.view_table_usage dep
join information_schema.columns cols
  on cols.table_schema = dep.table_schema
	and cols.table_name = dep.table_name
  where dep.view_schema = '$SCHEMA'
"

eval "${SQL_CMD} -c \"${COLUMN_SQL}\" > .sdc.tmp"

cat $TMP_FILE | cut -d ' ' -f2 | sort -u | while read TABLE; do
	echo "Backing up $TABLE"
	backup_table $TABLE
done
