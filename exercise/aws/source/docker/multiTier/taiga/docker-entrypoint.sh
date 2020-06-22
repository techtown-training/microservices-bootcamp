#!/bin/bash

WORKINGDIR=$PWD

# Setup database automatically if needed
if [ "$TAIGA_SKIP_DB_CHECK" != "True" ]; then
  echo "Running database check"
  python /scripts/checkdb.py
  DB_CHECK_STATUS=$?

  if [ $DB_CHECK_STATUS -eq 1 ]; then
    echo "Failed to connect to database server or database does not exist."
    exit 1
  fi

  # Database migration check should be done in all startup in case of backend upgrade
  echo "Check for database migration"
  python manage.py migrate --noinput

  if [ $DB_CHECK_STATUS -eq 2 ]; then
    echo "Configuring initial database"
    python manage.py loaddata initial_user
    python manage.py loaddata initial_project_templates
    python manage.py loaddata initial_role
  fi
else
  echo "Bypassing database check on user request"
fi

# In case of frontend upgrade, locales and statics should be regenerated
python manage.py compilemessages > /dev/null
python manage.py collectstatic --noinput > /dev/null


# configure the slack contrib plugin
source /scripts/config-slack-plugin.sh

HOSTNAME_TAIGA_URL="http://$TAIGA_HOSTNAME/api/v1/"
HOSTNAME_TAIGA_URL_EVENTS="ws://$TAIGA_HOSTNAME/events"

# Handle enabling/disabling SSL
if [ "$TAIGA_SSL_BY_REVERSE_PROXY" = "True" ] || [ "$TAIGA_SSL" = "True" ]; then
  echo "Enabling SSL support!"
  HOSTNAME_TAIGA_URL="https://$TAIGA_HOSTNAME/api/v1/"
  HOSTNAME_TAIGA_URL_EVENTS="wss://$TAIGA_HOSTNAME/events"
fi

# Automatically replace "TAIGA_HOSTNAME" with the environment variable
PYTHON_CMD='import modify_conf; modify_conf.modifyJSONFile("/taiga/conf.json","api","'"$HOSTNAME_TAIGA_URL"'")'
echo "Invoke $PYTHON_CMD"
cd /scripts/ && python -c "$PYTHON_CMD"
cd $WORKINGDIR

# Look to see if we should set the "eventsUrl"
if [ ! -z "$RABBIT_PORT_5672_TCP_ADDR" ]; then
  echo "Enabling Taiga Events"
  PYTHON_CMD='import modify_conf; modify_conf.modifyJSONFile("/taiga/conf.json","eventsUrl","'"$HOSTNAME_TAIGA_URL_EVENTS"'")'
  cd /scripts/ && python -c "$PYTHON_CMD"
  cd $WORKINGDIR
fi

# Look to see if we should enable registration
if [ ! -z "$TAIGA_REGISTER_ENABLED" ]; then
  echo "Configuring registration"
  PYTHON_CMD='import modify_conf; modify_conf.modifyJSONFile("/taiga/conf.json","publicRegisterEnabled",'$TAIGA_REGISTER_ENABLED')'
  cd /scripts/ && python -c "$PYTHON_CMD"
  cd $WORKINGDIR
fi

# Reinitialize nginx links
rm /etc/nginx/sites-enabled/*
if [ "$TAIGA_SSL" = "True" ]; then
  if [ ! -z "$RABBIT_PORT_5672_TCP_ADDR" ]; then
    ln -s /etc/nginx/sites-available/taiga-ssl /etc/nginx/sites-enabled/taiga-events-ssl
  else
    ln -s /etc/nginx/sites-available/taiga-ssl /etc/nginx/sites-enabled/taiga-ssl
  fi
else
  if [ ! -z "$RABBIT_PORT_5672_TCP_ADDR" ]; then
    ln -s /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga-events
  else
    ln -s /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga
  fi
fi

# Start nginx service (need to start it as background process)
service nginx start

# Start gunicorn  server
exec "$@"