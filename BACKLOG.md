# BACKLOG : Carnet de désirs

## 2023-08-09

app.gvois.in doit pointer vers guichet.gvois.in  

guichet.gvois.in doit fonctionner

Je pense devoir utiser resdigita.org selon accord de Conseil des Voisins  

Migrer depuis vpsfree à hetzner

### Migration sortant de Scaleway

```
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-73-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed Aug  9 12:14:29 PM CEST 2023

  System load:                      0.45361328125
  Usage of /:                       24.2% of 936.04GB
  Memory usage:                     59%
  Swap usage:                       0%
  Temperature:                      64.0 C
  Processes:                        749
  Users logged in:                  1
  IPv4 address for br-0be62abd5c4c: 172.19.0.1
  IPv4 address for br-caac48d403d0: 172.18.0.1
  IPv4 address for docker0:         172.17.0.1
  IPv4 address for eno1:            51.159.76.154
  IPv4 address for eno1:            51.159.223.7
  IPv6 address for eno1:            2001:bc8:1201:900:46a8:42ff:fe22:e5b6
  IPv6 address for eno1:            2001:bc8:1203:79::
  IPv4 address for ldapbr0:         10.250.252.1
  IPv6 address for ldapbr0:         fd42:2455:9063:1118::1
  IPv4 address for lxdbr0:          10.147.30.1
  IPv6 address for lxdbr0:          fd42:fdb4:c742:8a23::1
  IPv4 address for lxdbr1:          10.223.31.1
  IPv6 address for lxdbr1:          fd42:1e15:8127:80d9::1

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

 * Introducing Expanded Security Maintenance for Applications.
   Receive updates to over 25,000 software packages with your
   Ubuntu Pro subscription. Free for personal use.

     https://ubuntu.com/pro


Expanded Security Maintenance for Applications is not enabled.

76 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


*** System restart required ***
Last login: Sun Jul 30 17:33:37 2023 from 92.154.119.48
```

```
root@idgovern:/etc/apache2/sites-enabled# lxc list                                                              +---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
|     NAME      |  STATE  |             IPV4             |                      IPV6                      |   TYPE    | SNAPSHOTS |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| aaalesgvcom   | RUNNING | 10.147.30.31 (eth0)          | fd42:fdb4:c742:8a23:216:3eff:fe00:3065 (eth0)  | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| alphalesgvcom | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| bind          | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| contaboa      | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| contaboa2     | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| cozy          | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| discourse     | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| docker        | RUNNING | 172.18.0.1 (br-627c78fee3f2) | fd42:fdb4:c742:8a23:216:3eff:fe53:733d (eth0)  | CONTAINER | 0         |
|               |         | 172.17.0.1 (docker0)         |                                                |           |           |
|               |         | 10.147.30.35 (eth0)          |                                                |           |           |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| forgehopgvcom | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| front         | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| ghostio       | RUNNING | 10.147.30.151 (eth0)         | fd42:fdb4:c742:8a23:216:3eff:fec9:de31 (eth0)  | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| gitea         | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| hetznerc      | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| ikoulac       | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| iredmail      | RUNNING | 10.147.30.241 (eth0)         | fd42:fdb4:c742:8a23:f87b:28a4:5d0f:cb0c (eth0) | CONTAINER | 0         |
|               |         |                              | fd42:fdb4:c742:8a23:e69b:f5d6:b196:9792 (eth0) |           |           |
|               |         |                              | fd42:fdb4:c742:8a23:e3ed:80e9:55c2:ab3a (eth0) |           |           |
|               |         |                              | fd42:fdb4:c742:8a23:9391:cbde:e413:551c(eth0)  |           |           |  
|               |         |                              | fd42:fdb4:c742:8a23:85f3:b56:2c6c:42e2 (eth0)  |           |           | 
|               |         |                              | fd42:fdb4:c742:8a23:748a:32a1:3bb4:9ec2 (eth0) |           |           |
|               |         |                              | fd42:fdb4:c742:8a23:613a:62f2:a558:aa31 (eth0) |           |           |
|               |         |                              | fd42:fdb4:c742:8a23:5c78:e3b4:f21f:f688 (eth0) |           |           |
|               |         |                              | fd42:1e15:8127:80d9:216:3eff:fe32:8ec9 (eth1)  |           |           |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| keycloak      | STOPPED |                              |                                                | CONTAINER | 0         |+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| ldap          | STOPPED |                              |                                                | CONTAINER | 0         |+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| mmmlesgvcom   | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| nixian        | RUNNING | 10.147.30.19 (eth0)          | fd42:fdb4:c742:8a23:216:3eff:fef4:fd89 (eth0)  | CONTAINER | 0         |
|               |         |                              | fd42:1e15:8127:80d9:216:3eff:fe0f:ad2e (eth1)  |           |           |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| odoo          | RUNNING | 10.147.30.158 (eth0)         | fd42:fdb4:c742:8a23:216:3eff:feed:1605 (eth0)  | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| odoofor       | RUNNING | 10.147.30.173 (eth0)         | fd42:fdb4:c742:8a23:216:3eff:fecd:ba4 (eth0)   | CONTAINER | 1         |
|               |         |                              | fd42:1e15:8127:80d9:216:3eff:feb7:4d84 (eth1)  |           |           |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| odoothree     | RUNNING | 10.147.30.128 (eth0)         | fd42:fdb4:c742:8a23:216:3eff:fe67:e29d (eth0)  | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| odootoo       | RUNNING | 10.147.30.82 (eth0)          | fd42:fdb4:c742:8a23:216:3eff:fee3:e0ec (eth0)  | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| searx         | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| searxng       | STOPPED |                              |                                                | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
| wagtail       | RUNNING | 10.147.30.15 (eth0)          | fd42:fdb4:c742:8a23:216:3eff:fe3f:d33d (eth0)  | CONTAINER | 0         |
+---------------+---------+------------------------------+------------------------------------------------+-----------+-----------+
root@idgovern:/etc/apache2/sites-enabled#
```

### Running Servers

#### aaalesgvcom

user aaa

folders /home/aaa/aaa/ and /home/home/manndigital/

uses node and apostrophe-cms dependencies



#### docker

#### ghostio

#### iredmail

#### nixian

#### odoo

#### odoofor

#### odoothree

#### odootoo

#### wagtail

#### Apache

Apache a les sites suivants activés sur Scaleway: 

000-default.conf
actention.com.conf
actention.com.www.conf
agoodvillage.com.conf
agoodvillage.com.www.conf
avmeet.com.www.conf
caplancity.com.conf
caplancity.com.www.conf
communititude.com.conf
communititude.com.www.conf
configmagic.com.conf
configmagic.com.www.conf
coopgv.com.conf
coopgv.com.www.conf
coopgv.org.conf
coopgv.org.www.conf
demarchic.com.conf
demarchic.com.www.conf
distractives.com.conf
distractives.com.www.conf
focusplex.com.conf
focusplex.com.www.conf
gdvoisins.com.forum.conf
goodv.org.forum.conf
grandsvoisins.com.com.conf
grandsvoisins.com.conf
grandsvoisins.com.forum.conf
grandsvoisins.com.www.conf
gv.city.conf
gv.city.www.conf
hyperattention.com.conf
hyperattention.com.www.conf
iciwow.com.conf
iciwow.com.www.conf
idgouv.com.conf
idgouv.com.www.conf
irivi.org.conf
irivi.org.www.conf
lesartsvoisins.com.conf
lesartsvoisins.com.www.conf
lesgrandsvoisins.com.aaa.conf
lesgrandsvoisins.com.blog.conf
lesgrandsvoisins.com.carecaring.conf
lesgrandsvoisins.com.com.conf
lesgrandsvoisins.com.conf
lesgrandsvoisins.com.forum.conf
lesgrandsvoisins.com.lhomme.conf
lesgrandsvoisins.com.mael.conf
lesgrandsvoisins.com.mailing.conf
lesgrandsvoisins.com.mann.conf
lesgrandsvoisins.com.meet.conf
lesgrandsvoisins.com.old.conf
lesgrandsvoisins.com.ooo.conf
lesgrandsvoisins.com.www.conf
lesgrandsvoisins.fr.www.conf
lesgv.com.conf
lesgv.com.discourse.conf
lesgv.com.www.conf
l-g-v.com.conf
l-g-v.com.www.conf
lgv.coop.actention.conf
lgv.coop.conf
lgv.coop.meet.conf
lgv.coop.odoo.conf
lgv.coop.ooo.conf
lgv.coop.www.conf
l-g-v.org.conf
l-g-v.org.www.conf
maelanc.com.conf
maelanc.com.www.conf
managence.com.conf
managence.com.www.conf
mann.city.conf
mann.city.www.conf
mann.coach.conf
mann.coach.www.conf
mann.digital.conf
mann.digital.old.conf
mann.digital.www.conf
mann.fr.conf
mann.fr.www.conf
popupos.com.conf
popupos.com.www.conf
quiquoietc.com.conf
quiquoietc.com.www.conf
resdigita.com.conf
resdigita.com.web.conf
resdigita.com.www.conf
resolvactive.com.conf
resolvactive.com.www.conf
taskwhy.com.conf
taskwhy.com.www.conf
tel.lgv.coop.conf
toutdouxlisse.com.conf
toutdouxlisse.com.www.conf
villagevoisin.com.conf
villagevoisin.com.www.conf
voisand.com.conf
voisand.com.www.conf
voisand.org.conf
voisand.org.www.conf
whowhatetc.com.conf
whowhatetc.com.www.conf