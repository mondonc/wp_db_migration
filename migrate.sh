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


# Replace siteurls
sed -i -e "s#'siteurl','http://${OLD}/#'siteurl','http://${NEW}/#g" $FILE
sed -i -e "s#'siteurl','https://${OLD}/#'siteurl','https://${NEW}/#g" $FILE

# Replace homes
sed -i -e "s#'home','http://${OLD}/#'home','http://${NEW}/#g" $FILE
sed -i -e "s#'home','https://${OLD}/#'home','https://${NEW}/#g" $FILE

# Replace fileUpload 
sed -i -e "s#'fileupload_url','http://${OLD}/#'fileupload_url','http://${NEW}/#g" $FILE
sed -i -e "s#'fileupload_url','https://${OLD}/#'fileupload_url','https://${NEW}/#g" $FILE

# To fix others stuffs in DB: 
# UPDATE wp_options SET option_value = replace(option_value, 'https://${OLD}', 'https://${NEW}') WHERE option_name = 'home' OR option_name = 'siteurl';
# UPDATE wp_posts SET guid = replace(guid, 'https://${OLD}','https://${NEW}');
# UPDATE wp_posts SET post_content = replace(post_content, 'https://${OLD}', 'https://${NEW}');
# UPDATE wp_blogs SET domain = replace(domain, '${OLD}', '${NEW}');
# UPDATE wp_site SET domain = replace(domain, '${OLD}', '${NEW}');

# OR You can try this instead
#echo "Replacing all remaining occurences"
#sudo sed -i -e "s/${OLD}/${NEW}/g" "$FILE"


# Then, in worpress root dir : 
#for f in `find . -name '*.php'` ; do sudo sed -i -e "s/${OLD}/${NEW}/g" "$f" ; done
#for f in `find . -name '*.js'` ; do sudo sed -i -e "s/${OLD}/${NEW}/g" "$f" ; done
#for f in `find . -name '*.html'` ; do sudo sed -i -e "s/${OLD}/${NEW}/g" "$f" ; done
