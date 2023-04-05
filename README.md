# Fieldsets Event Logger

We utilize the lightweight Fluent Bit log forwarder to centralize our logs and create our custom fieldsets container events. These events are recorded in our PostgreSQL database as a table that is partitioned by year/month. For speed purposes, the tables found in the PostgreSQL `pipeline` schema do not write to the Write-Ahead-Log (WAL) and are set as `UNLOGGED`.

You can run this logger as a docker service or you can follow the instructions here to install a standalone binary. This binary can the be utilized with the included conf files.

Add the following code in `docker-compose.override.yml` to the service you wish to add centralized logging to.
```
logging:
    driver: fluentd
    options:
        fluentd-address: ${LOGGER_HOST:-172.28.0.2}:${LOGGER_PORT:-24224}
        tag: debug_log
        fluentd-async: "true"
        env: "PGOPTIONS='-c search_path=pipeline'"
```
