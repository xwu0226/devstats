#!/bin/bash
function finish {
    sync_unlock.sh
}
trap finish EXIT
sync_lock.sh
set -o pipefail
> errors.txt
> run.log
GHA2DB_PROJECT=opentracing IDB_DB=opentracing PG_DB=opentracing GHA2DB_LOCAL=1 ./structure 2>>errors.txt | tee -a run.log || exit 1
GHA2DB_PROJECT=opentracing IDB_DB=opentracing PG_DB=opentracing GHA2DB_LOCAL=1 ./gha2db 2015-11-26 0 today now 'opentracing' 2>>errors.txt | tee -a run.log || exit 2
GHA2DB_PROJECT=opentracing IDB_DB=opentracing PG_DB=opentracing GHA2DB_LOCAL=1 GHA2DB_MGETC=y GHA2DB_SKIPTABLE=1 GHA2DB_INDEX=1 ./structure 2>>errors.txt | tee -a run.log || exit 3
./grafana/influxdb_recreate.sh opentracing
./opentracing/setup_repo_groups.sh 2>>errors.txt | tee -a run.log || exit 4
./opentracing/import_affs.sh 2>>errors.txt | tee -a run.log || exit 5
./opentracing/setup_scripts.sh 2>>errors.txt | tee -a run.log || exit 6
./opentracing/get_repos.sh 2>>errors.txt | tee -a run.log || exit 7
echo "All done. You should run ./opentracing/reinit.sh script now."
