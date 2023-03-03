#!/usr/bin/env bash

#===
# Event Emitter for environments without docker.
# See shell coding standards for details of formatting. 
# https://github.com/Fieldsets/fieldsets-pipeline/blob/main/docs/developer/coding-standards/shell.md
#===

set -eEa -o pipefail

#===
# Variables
#===

event_name=$1
pipeline_name=$2
status=$3
metadata=$4

#===
# Functions
#===

##
# event_emitter: Forward event JSON to our event listener
# @param STRING: event_name
# @param STRING: pipeline_name
# @param JSON: metadata
#
# @requires ENVVAR: $POSTGRES_HOST
# @requires ENVVAR: $POSTGRES_PORT
# @requires ENVVAR: $POSTGRES_USER
# @requires ENVVAR: $POSTGRES_PASSWORD
# @requires ENVVAR: $POSTGRES_DB
#
# @requires PROGRAM: fluent-bit
# @requires PROGRAM: jq
##
event_emitter() {
    local db_schema="${PGOPTIONS}"

    export PGOPTIONS='-c search_path=pipeline'
    printf '{"fieldsets_event": "%s", "pipeline": "%s", "event_status": %s "meta_data": %s}' "${event_name}" "${pipeline_name}" "${status}" "${metadata}" | \
        jq '.' | \
        fluent-bit -i stdin -t "event_log" -o pgsql -p "Host=${POSTGRES_HOST:-172.28.0.7}" -p "Port=${POSTGRES_PORT:-5432}" -p "User=${POSTGRES_USER:-postgres}" -p "Password=${POSTGRES_PASSWORD:-fieldsets}" -p "Database=${POSTGRES_DB:-fieldsets}" -p "Table=events"

    # Set PGOPTIONS back in case this shared functiion is called with this value set.
    export PGOPTIONS="${db_schema}"
}

#===
# Main
#===
trap traperr ERR

event_emitter
