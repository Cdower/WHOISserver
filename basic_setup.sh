#-i  all sudo? run script as sudo?

yum install epel-release.noarch
yum -y install mariadb-server mariadb

#make MySWL run on boot
systemctl enable mariadb.service
systemctl start mariadb.service
#setup password and stuff ignore for now
#mysql_secure_installation

yum -y install pdns pdns-backend-mysql
