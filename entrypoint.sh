#!/bin/bash

if [[ -d /opt/config ]]; then
	mv /opt/config/* /opt/homs/config
	rm -f /opt/config
fi
cd /opt/homs
sed -i -e "s/localhost/$ACTIVITI_HOST/" config/activiti.yml.sample
sed -i -e "s/localhost/$DB_HOST/" config/database.yml.sample
find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
bundle exec rake db:migrate

if [[ ! -a seed.lock || "$FORCE_DB_SEED" = "yes" ]]; then 
	bundle exec rake db:seed
	touch seed.lock
fi

thin config -C config/thin.yml
thin start --threaded -C config/thin.yml
