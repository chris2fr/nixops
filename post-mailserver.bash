mkdir -p /var/www/SOGo/
cp -a /run/current-system/sw/lib/GNUstep/SOGo/WebServerResources /var/www/SOGo/
chown wwwrun:users -R /var/www/SOGo/WebServerResources/
mkdir -p /var/www/resdigitacom
chown wwwrun:users -R /var/www/resdigitacom
chmod g+w /var/www/resdigitacom
chmod +s /var/www/resdigitacom