#!/bin/bash

# WP Domain changes

# Author Clément Mondon <clement.mondon_navazo@inria.fr>
# Copyright Inria

OLD="www.OLD_DOMAIN.com"
NEW="www.SUPERNEW_DOMAIN.com"

if [ -z "$1" ] ; then
	echo "Syntax $0 DB_DUMP_FILE"
	exit 1
fi

DELTA=`expr ${#NEW} - ${#OLD}` # Diff between 2 domains
FILE=$1

echo "Patching $FILE"

# Extract all serialized occurences
tmpfile=$(mktemp /tmp/wp_mig.XXXXXX)
grep -oE "s:[0-9]*:\\\\\"https://${OLD}" $FILE | sort | uniq > $tmpfile

# Replace all serialized occurences with new domain and good length
while read line; do

	NB_OLD=`echo $line | cut -d ':' -f 2`
	NB=`expr ${NB_OLD} + ${DELTA}`

	echo Applying sudo sed -i -e "s#s:${NB_OLD}:\\\"https://${OLD}#s:${NB}:\\\"https://${NEW}#g" $FILE
	sudo sed -i -e "s#s:${NB_OLD}:\\\\\"https://${OLD}#s:${NB}:\\\\\"https://${NEW}#g" $FILE

done <$tmpfile

echo "Replacing all remaining occurences"
sudo sed -i -e "s/${OLD}/${NEW}/g" "$FILE"
