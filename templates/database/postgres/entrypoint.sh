

function check_database
{
    database=$1
    psql -U$PG_USERNAME -c "SELECT datname FROM pg_database WHERE  datname = '$database'" | grep $database

    if [[ $? != 0 ]]; then
        psql -U$PG_USERNAME -c "create database $database"
    fi
}
check_database $PG_DB_NAME
check_database headscale
check_database cylonix_supervisor