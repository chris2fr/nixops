for i in bind adminresdigitaorg alice sogo bob
do
  echo $i
  echo `echo $RANDOM | md5sum | head -c 20;` > /etc/nixos/.secrets.mailserver.$i
  chmod 0500 /etc/nixos/.secrets.mailserver.$i
done
mv /etc/nixos/.secrets.mailserver.adminresdigitaorg /etc/nixos/.secrets.adminresdigitaorg
