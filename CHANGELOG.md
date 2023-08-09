# CHANGELOG : Journal des interventions

## 2023-08-09

Mise en place de Hetzner on 

```
mannchri@CMANNFRLENOVO:/mnt/d/seafile/chris/chris$ nslookup gvois.in
Server:         172.19.160.1
Address:        172.19.160.1#53

Non-authoritative answer:
Name:   gvois.in
Address: 116.202.236.241
Name:   gvois.in
Address: 2a01:4f8:241:4faa::1
```

```
mannchri@CMANNFRLENOVO:/mnt/d/seafile/chris/chris$ nslookup mail.gvois.in
Server:         172.19.160.1
Address:        172.19.160.1#53

Non-authoritative answer:
Name:   mail.gvois.in
Address: 116.202.236.241
Name:   mail.gvois.in
Address: 2a01:4f8:241:4faa::2
```

avec utilisateurs :

* root
* mannchri
* wagtail
* guichet

### Opérations manuelles d'installation

https://nixos.org/manual/nixos/stable/#sec-installation

Intervention de Hetzner pour installer

```
- [root@lesgrandsvoisins:~/nixops/hetzner]# mkdir /var/www
- [root@lesgrandsvoisins:~/nixops/hetzner]# chown wwwrun:wwwrun /var/www
- [root@lesgrandsvoisins:~/nixops/hetzner]# chmod +s /var/www
- [root@lesgrandsvoisins:~/nixops/hetzner]# su - guichet
- [root@lesgrandsvoisins:~/nixops/hetzner]# nix-env --list-generations --profile /nix/var/nix/profiles/system
- [root@lesgrandsvoisins:~]# ln -s /nix/var/nix/profiles/system/sw/lib/GNUstep/SOGo/ /var/www/SOGo
```