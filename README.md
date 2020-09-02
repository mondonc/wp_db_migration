# WordPress DB Domain Migration

A small script to patch a DB dump to change domain, dealing with serialized string lengths.

## After, you have to : 

### To fix others stuffs in DB: 

UPDATE wp_options SET option_value = replace(option_value, 'https://${OLD}', 'https://${NEW}') WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = replace(guid, 'https://${OLD}','https://${NEW}');
UPDATE wp_posts SET post_content = replace(post_content, 'https://${OLD}', 'https://${NEW}');
UPDATE wp_blogs SET domain = replace(domain, '${OLD}', '${NEW}');
UPDATE wp_site SET domain = replace(domain, '${OLD}', '${NEW}');

### Then, in worpress root dir : 

for f in `find . -name '*.php'` ; do sudo sed -i -e "s/${OLD}/${NEW}/g" "$f" ; done
for f in `find . -name '*.js'` ; do sudo sed -i -e "s/${OLD}/${NEW}/g" "$f" ; done
for f in `find . -name '*.html'` ; do sudo sed -i -e "s/${OLD}/${NEW}/g" "$f" ; done
