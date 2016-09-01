#!/bin/bash

###
# stitch v2 redshift migrator
#
# Migrates Stitch data in Redshift to a v2-compatible structure.
# This script is provided as-is and should be used with caution.
#
# TODO PGPASSWORD doesn't appear to be used here?
# TODO my preference wolud be for a dry-run argument rather than an
# environment variable
# TODO you're subtly breaking gnu conventions which isn't the end of the
# world but traditionally long arguments are `--long=foo` and short are
# `-l foo`. up to you
# Usage: PGPASSWORD=mypass DRY_RUN=true bash migrate.sh --user my-stitch-user --host mydb.abcdef1234.us-east-1.redshift.amazonaws.com --port 5439 --database mydb --schema my_schema
#
# The above will print the backup commands the script
# would run, set DRY_RUN=false to actually run them.
#
##

# TODO I believe you want this to be (( $# > 1 )) since it's an arithmetic
# comparison
while [[ $# -gt 1 ]]
do
key="$1"

# TODO i'd personally rename all the variables here to lower case. see
# http://mywiki.wooledge.org/BashGuide/InputAndOutput#The_Environment
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

# TODO since we're trying to execute this later it should be an
# array. http://mywiki.wooledge.org/BashFAQ/050
SQL_CMD="psql --host $HOST --port $PORT --user $USER $DATABASE --no-align --quiet -t --field-separator ' '"
# TODO might consider using `mktemp` here.
TMP_FILE=".sdc.tmp"
TMP_SQL_FILE=".sdc.sql.tmp"

backup_table ()
{
	TABLE=$1
        # TODO this method of building up an array is a little dangerous
        # as there can be subtle word-splitting bugs. Unless you can be
        # 100% certain that you won't fall afoul of that, you should build
        # these up using `read -r` and a while loop over the results.
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
            # TODO not sure i follow the need for eval here. Why not just execute it?
            # "${SQL_CMD[@]}" -f "$TMP_SQL_FILE"
		eval "${SQL_CMD} -f ${TMP_SQL_FILE}"
	fi

}

# TODO looks like we've mixed tabs and spaces here
# TODO generally don't we put the commas at the end of the line they're on?
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

# TODO same confusion about eval here.
# TODO think you mean to use $TMP_FILE here
eval "${SQL_CMD} -c \"${COLUMN_SQL}\" > .sdc.tmp"

# TODO in general just quote every variable expansion.
cat $TMP_FILE | cut -d ' ' -f2 | sort -u | while read TABLE; do
	echo "Backing up $TABLE"
	backup_table $TABLE
done
