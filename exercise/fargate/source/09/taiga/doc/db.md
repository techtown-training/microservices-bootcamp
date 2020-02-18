Configure Database
==================

The above example uses `--link` to connect Taiga with a running [postgres](https://registry.hub.docker.com/_/postgres/) container. This is probably not the best idea for use in production, keeping data in docker containers can be dangerous.

Using Docker container
----------------------

If you want to run your database within a docker container, simply start your database server before starting your Taiga container. Here is a simple example pulled from [postgres](https://registry.hub.docker.com/_/postgres/)'s guide.

    docker run --name taiga-postgres -e POSTGRES_PASSWORD=mypassword -d postgres

Using Database server
---------------------

Use the following, **required**, environment variables for connecting to another database server:

 - `-e TAIGA_DB_NAME=...` (defaults to `postgres`)
 - `-e TAIGA_DB_HOST=...` (defaults to the address of a linked `postgres` container)
 - `-e TAIGA_DB_USER=...` (defaults to `postgres)`)
 - `-e TAIGA_DB_PASSWORD=...` (defaults to the password of the linked `postgres` container)

The following environment variable is mandatory

 - `-e TAIGA_DB_TIMEOUT=...` (number of connexion try, each 250ms, by defautl 240 for 1 minute)

If the `TAIGA_DB_NAME` specified does not already exist on the provided PostgreSQL server, it will be automatically created the the Taiga's installation scripts will run to generate the required tables and default demo data.

An example `docker run` command using an external database:

    docker run \
      --name mytaiga \
      -e TAIGA_DB_HOST=10.0.0.1 \
      -e TAIGA_DB_USER=taiga \
      -e TAIGA_DB_PASSWORD=mypassword \
      -itd \
      novanet/taiga
