#!/bin/bash
. ./devel/all_dbs.sh || exit 2
for db in $all
do
    echo "DB: $db"
    ./devel/restore_db.sh $db || exit 2
done
echo 'OK'
