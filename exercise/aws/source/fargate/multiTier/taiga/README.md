Docker Image for Taiga
======================

What is Taiga?
--------------

Taiga is a project management platform for startups and agile developers & designers who want a simple, beautiful tool that makes work truly enjoyable.

> [taiga.io](https://taiga.io)

Requirements
------------

You need to setup a posgresql container to store your database information.

Quick setup
-----------

The simpliest way to run a local server is to update docker-compose.yml and launch it with:

```bash
docker-compose up
```

Please look the config.env to know all possible environment variables.

General setup
-------------

You can get the image directly from dockerhub with and link it with postgres:

```bash
docker run -itd \
    --link taiga-postgres:postgres \
    -p 80:80 \
    -e TAIGA_HOSTNAME=taiga.mycompany.net \
    -e TAIGA_SECRET_KEY="!!!REPLACE-ME!!!" \
    -e TAIGA_DB_HOST=postgres \
    -e TAIGA_DB_USER=postgres \
    -e TAIGA_DB_PASSWORD=password \
    -v ./media:/usr/src/taiga-back/media \
    novanet/taiga
```

See `Summarize` below for a complete example. Partial explanation of arguments:

  - `--link` is used to link a database container. See [Configure Database](doc/db.md) for more details.
  - `-v` is used to mount a media folder from host. It is necessary to keep your uploaded data safe.

Once your container is running, use the default administrator account to login: username is `admin`, and the password is `123123`.

If you're having trouble connecting, make sure you've configured your `TAIGA_HOSTNAME`. It will default to `localhost`, which almost certainly is not what you want to use.

### Extra configuration options

Use the following environmental variables to generate a `local.py` for [taiga-back](https://github.com/taigaio/taiga-back).

  - `-e TAIGA_HOSTNAME=` (**required** set this to the server host like `taiga.mycompany.com`)
  - `-e TAIGA_SSL=True` (see [Enabling HTTPS](doc/https.md))
  - `-e TAIGA_SECRET_KEY` (set this to a random string to configure the `SECRET_KEY` value for taiga-back; defaults to an insecure random string)
  - `-e TAIGA_SKIP_DB_CHECK` (set to skip the database check that attempts to automatically setup initial database)
  - `-e TAIGA_ENABLE_EMAIL=True` (see [Configuring SMTP](doc/mail.md))
  - `-e TAIGA_REGISTER_ENABLED=True` (enable public registration)
  - `-e TAIGA_SLACK=True` (to configure the plugin, visit the [Taiga documentation](https://tree.taiga.io/support/contrib-plugins/slack-integration))

*Note*: Database variables are also required, see [Using Database server](doc/db.md). These are required even when using a container for your database.

### Volumes

Uploads to Taiga go to the media folder, located by default at `/usr/src/taiga-back/media`.

Use `-v /my/own/media:/usr/src/taiga-back/media` as part of your docker run command to ensure uploads are not lost easily.

### Events

Taiga has an optional dependency that adds additional usability to Taiga (like broadcasting updates to other clients), see [Taiga Events](doc/events.md).

Full setup
----------

To sum it all up, if you want to run Taiga without using docker-compose, run this:

    docker run --name taiga-postgres -d -e POSTGRES_PASSWORD=password postgres
    docker run --name taiga-redis -d redis:3
    docker run --name taiga-rabbit -d --hostname taiga rabbitmq:3
    docker run --name taiga-celery -d --link taiga-rabbit:rabbit celery
    docker run --name taiga-events -d --link taiga-rabbit:rabbit novanet/taiga-events

    docker run -itd \
      --name taiga \
      --link taiga-postgres:postgres \
      --link taiga-redis:redis \
      --link taiga-rabbit:rabbit \
      --link taiga-events:events \
      -p 80:80 \
      -e TAIGA_HOSTNAME=$(docker-machine ip default) \
      -v ./media:/usr/src/taiga-back/media \
      novanet/taiga
