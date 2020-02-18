Taiga Events
============

Taiga has an optional dependency, [taiga-events](https://github.com/taigaio/taiga-events).
This adds additional usability to Taiga (like broadcasting updates to other clients).
To support this, there is an optional docker dependency available called [docker-taiga-events](https://github.com/ajira86/docker-taiga-events).
It has a few dependencies of its own, so this is how you run it:

```bash
# Setup RabbitMQ and Redis services
docker run --name taiga-redis -d redis:3
docker run --name taiga-rabbit -d --hostname taiga rabbitmq:3

# Start up a celery worker
docker run --name taiga-celery -d --link taiga-rabbit:rabbit celery

# Now start the taiga-events server
docker run --name taiga-events -d --link taiga-rabbit:rabbit novanet/taiga-events
```

Then append the following arguments to your `docker run` command running your `novanet/taiga` container:

    --link taiga-rabbit:rabbit
    --link taiga-redis:redis
    --link taiga-events:events

See the example below in `Summarize` section for an example `docker run` command.
