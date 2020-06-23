#!/bin/bash

WORKINGDIR=$PWD


TAGIA_SLACK_CONFIG_BACKEND='## Slack
# https://github.com/taigaio/taiga-contrib-slack
INSTALLED_APPS += ["taiga_contrib_slack"]'


TAGIA_SLACK_CONFIG_FRONTED="/plugins/slack/slack.json"

TAIGA_CONFIG_FILE_BACKEND="/taiga/local.py"

TAIGA_CONFIG_FILE_FRONTEND="/taiga/conf.json"

SLACK_FOLDER="/usr/src/taiga-front-dist/dist/plugins/slack/"

download_taiga () {
  echo "Start to download slack plugin"
  if [ -d "$SLACK_FOLDER" ]; then
    echo "slack already downloaded"
  fi
  pip install --no-cache-dir taiga-contrib-slack
  mkdir -p "$SLACK_FOLDER"
  SLACK_VERSION=$(pip show taiga-contrib-slack | awk '/^Version: /{print $2}')
  echo "taiga-contrib-slack version: $SLACK_VERSION" 
  curl https://raw.githubusercontent.com/taigaio/taiga-contrib-slack/$SLACK_VERSION/front/dist/slack.js -o "$SLACK_FOLDER/slack.js" 
  curl https://raw.githubusercontent.com/taigaio/taiga-contrib-slack/$SLACK_VERSION/front/dist/slack.json -o "$SLACK_FOLDER/slack.json"
  echo "Successfully downloaded slack-contrib"
}


activate_slack () {
 # activate in the backend
  echo "Activate slack plugin in backend and fronted"
  if grep -Fxq "$TAGIA_SLACK_CONFIG_BACKEND" "$TAIGA_CONFIG_FILE_BACKEND"
  then
      # backend is already configured 
      echo "Slack already actived in backend"
  else
      # backend is not configured
      echo "Activate Slack in backend"
      echo "" >> "$TAIGA_CONFIG_FILE_BACKEND"
      echo "$TAGIA_SLACK_CONFIG_BACKEND" >> "$TAIGA_CONFIG_FILE_BACKEND"
      echo "Slack actived in backend"
  fi

   # activate in the fronted
  if grep -Fxq "$TAGIA_SLACK_CONFIG_FRONTED" "$TAIGA_CONFIG_FILE_FRONTEND"
  then
      # frontend is configured
      echo "Slack already actived in fronted"
  else
      # frontend is not  configured
      echo "Activate Slack in fronted"
      PYTHON_CMD='import modify_conf; modify_conf.modifyJSONFile("/taiga/conf.json","contribPlugins","'"$TAGIA_SLACK_CONFIG_FRONTED"'")'
      cd /scripts/ && python -c "$PYTHON_CMD"
      cd $WORKINGDIR
      echo "Slack actived in fronted"
  fi
}


deactivate_slack () {
  echo "Dectivate slack plugin in backend and frontend"
  if grep -Fxq "$TAGIA_SLACK_CONFIG_BACKEND" "$TAIGA_CONFIG_FILE_BACKEND"
  then
      # slack is active in the backend
      echo "Deactivate Slack in backend"
      # for one reasion I cannot use the complete TAIGA_SLACK_CONFIG variable here
      PATTERNTOREMOVE="INSTALLED_APPS += [\"taiga_contrib_slack\"]"
      safe_pattern=$(printf '%s\n' "$PATTERNTOREMOVE" | sed 's/[]\[\.*^$(){}|/#"]/\\&/g' )
      # now we can safely do
      sed -i '/'"${safe_pattern}"'/d' "$TAIGA_CONFIG_FILE_BACKEND"
      echo $safe_pattern
      echo "Slack deactived in backend"
  else
      # slack is not active in the bacnekd
      echo "Slack already deactived in backend"
  fi

  # activate in the fronted
  if grep -Fxq "$TAGIA_SLACK_CONFIG_FRONTED" "$TAIGA_CONFIG_FILE_FRONTEND"
  then
      # frontend is configured
      echo "Deactivate Slack in fronted"
      PYTHON_CMD='import modify_conf; modify_conf.modifyJSONFile("/taiga/conf.json","contribPlugins","'"$TAIGA_CONFIG_FILE_FRONTEND"'",True)'
      cd /scripts/ && python -c "$PYTHON_CMD"
      cd $WORKINGDIR
      echo "Slack deactived in fronted"
  else
      echo "Slack already deactived in fronted"
  fi
}



# Setup database automatically if needed
if [ ! -z "$TAIGA_SLACK" ]; then
  echo "Configure slack-contrib plugin"
  
  if [ "$TAIGA_SLACK" = "True" ]; then
    result=$(download_taiga)
    activate_slack
    echo "Received ${result}"
    echo "Migrate Slack Plugin"
    python manage.py migrate taiga_contrib_slack
  fi

  if [ "$TAIGA_SLACK" = "False" ]; then
    deactivate_slack
  fi

fi
