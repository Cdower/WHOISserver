# WHOISserver
A python whois server written to the RFC 3912 standard designed to be setup as a service on Centos 7 as a systemd service using PowerDNS for the DNS Server.

To properly setup this server run basic_setup.sh as root with the -i flag from the directory its in.
ex.
sudo ./basic_setup.sh -i

This will initialize mysql and all the databases it needs. 

#"-u " flag, 
  will add another 100 A records (without restarting the service) (e.g. r1001.test.com through r1100.test.com)
  
#"-m " flag, 
  will execute an AXFR zone transfer and report if the zone has changed more than 15% from the last time this option was executed

This server will properly respond to   whois   and  dig  commands
