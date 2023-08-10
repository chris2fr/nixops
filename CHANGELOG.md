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


[guichet@lesgrandsvoisins:~/guichet]$  scp lesgrandsvoisins.com:/home/guichet/guichet/config.json /home/guichet/guichet/config.json
config.json   

[root@lesgrandsvoisins:~/nixops]# mkdir /var/lib/wagtail/

[root@lesgrandsvoisins:~/nixops]# mkdir /var/lib/wagtail/

[root@lesgrandsvoisins:~/nixops]# chown wagtail:users  /var/lib/wagtail/

[root@lesgrandsvoisins:~/nixops]# chmod +s  /var/lib/wagtail/

[root@lesgrandsvoisins:~/nixops]# su - wagtail

[wagtail@lesgrandsvoisins:~]$ ssh-keygen


[wagtail@lesgrandsvoisins:~]$ cat .ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCds00dHLrYnmzAfxI4RgjZNsD1g4qsxuATGF2TaMHofMxP9H8Raa59DciA+1EnErYZTKlTVO6OXMANpBCbrNSiE7TH4175jJx/X2a7qgbOqm5zgqMlQw027DvalSq7+ymCdGvcCLQk+DSP/9VPoViiczUDCU1k2zpKCw9sI0NWFxUWi3PhmZ4yrw935BciyL5UfU311BoHJ8no8WmgP1ta/fq1fCXeQD2dMtjr+n/uROXPr8W42vaxSdt54hWXafb0ajYyDye5UYETgPT2SntVIDokHBa0zO8lXuGswXGlmVIkskzg7EHDjJutLghA/MDnON+mppB90P3YuelylRggIshkL3x3OtVowWHyk14w78Mu+82PamSF/ZZIGkC+lqAAwFG9SweiEzsiaReEWKLvPuR2mp9zGJ9CRH+m2n4BYH0W0tXORgahKA5uSANCZEHTCePy8wAGpQvwcoJqEvdJCfTwWkcHCLnj/LvIdcs4Xu2VDYkUziu/aeGGPDiO6Ns= wagtail@lesgrandsvoisins

[wagtail@lesgrandsvoisins:~]$ git clone git@github.com:chris2fr/wagtail-lesgv.git

[wagtail@lesgrandsvoisins:~]$ python -m venv venv

[wagtail@lesgrandsvoisins:~]$ source venv/bin/activate

[wagtail@lesgrandsvoisins:~]$ cd wagtail-lesgv/

[wagtail@lesgrandsvoisins:~/wagtail-lesgv]$ pip install -r requirements.txt

[wagtail@lesgrandsvoisins:~/wagtail-lesgv]$ pip install --upgrade pip

[wagtail@lesgrandsvoisins:~/wagtail-lesgv]$ exit
déconnexion

[root@lesgrandsvoisins:~/nixops]# systemctl restart wagtail

[wagtail@lesgrandsvoisins:~/wagtail-lesgv]$ scp lesgrandsvoisins.com:/home/wagtail/wagtail-lesgv/lesgv/settings/secrets/lesecret.py /home/wagtail/wagtail-lesgv/lesgv/settings/secrets/lesecret.py

[root@lesgrandsvoisins:~/nixops]# mkdir /var/www/wagtail

[root@lesgrandsvoisins:~/nixops]# chown wagtail:users /var/www/wagtail

[root@lesgrandsvoisins:~/nixops]# chmod +s /var/www/wagtail

[wagtail@lesgrandsvoisins:~]$ cd /var/www/wagtail

[wagtail@lesgrandsvoisins:/var/www/wagtail]$ scp lesgrandsvoisins.com:/var/www/wagtail/favicon.ico .

[wagtail@lesgrandsvoisins:/var/www/wagtail]$ scp -r lesgrandsvoisins.com:/var/www/wagtail/media media

[ghostio@lesgrandsvoisins:~]$ npm install ghost-cli@latest -g

[root@lesgrandsvoisins:~]# mkdir /var/www/ghostio

[root@lesgrandsvoisins:~]# chown ghostio:users /var/www/ghostio

[root@lesgrandsvoisins:~]# chmod +s /var/www/ghostio

[ghostio@lesgrandsvoisins:/var/www/ghostio]$ ~/node_modules/ghost-cli/bin/ghost install local

[root@lesgrandsvoisins:~]# mkdir /home/ghost

[root@lesgrandsvoisins:~]# chown ghost:ghost /home/ghost

```

