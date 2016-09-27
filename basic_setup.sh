#-i  all sudo? run script as sudo/root?

yum install epel-release.noarch
yum -y install mariadb-server mariadb

#make MySWL run on boot
systemctl enable mariadb.service
systemctl start mariadb.service
#setup password and stuff ignore for now
#mysql_secure_installation

#Yum repo
yum install epel-release yum-plugin-priorities
curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo
#install pdns and backend
yum -y install pdns pdns-backend-mysql
