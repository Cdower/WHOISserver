key="$1"
MYSQL_USER='powerdns'
MYSQL_PASS='mysecretpassword'
case $key in
  -i)
  yum -y install epel-release.noarch
  yum -y install mariadb-server mariadb

  #make MySWL run on boot
  systemctl enable mariadb.service
  systemctl start mariadb.service
  #setup password and stuff ignore for now
  #mysql_secure_installation

  #Yum repo
  yum -y install epel-release yum-plugin-priorities
  curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo
  #install pdns and backend
  yum -y install pdns pdns-backend-mysql mysql-connector-python bc whois bind-utils

  mysql -u root -se "CREATE DATABASE powerdns;
GRANT ALL ON $MYSQL_USER.* TO 'powerdns'@'localhost' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL ON $MYSQL_USER.* TO 'powerdns'@'centos7.localdomain' IDENTIFIED BY '$MYSQL_PASS';
FLUSH PRIVILEGES;"
mysql -u $MYSQL_USER -p$MYSQL_PASS powerdns -se "
USE powerdns;
CREATE TABLE domains (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255) NOT NULL,
  master                VARCHAR(128) DEFAULT NULL,
  last_check            INT DEFAULT NULL,
  type                  VARCHAR(6) NOT NULL,
  notified_serial       INT DEFAULT NULL,
  account               VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE UNIQUE INDEX name_index ON domains(name);


CREATE TABLE records (
  id                    INT AUTO_INCREMENT,
  domain_id             INT DEFAULT NULL,
  name                  VARCHAR(255) DEFAULT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(64000) DEFAULT NULL,
  ttl                   INT DEFAULT NULL,
  prio                  INT DEFAULT NULL,
  change_date           INT DEFAULT NULL,
  disabled              TINYINT(1) DEFAULT 0,
  ordername             VARCHAR(255) BINARY DEFAULT NULL,
  auth                  TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);
CREATE INDEX recordorder ON records (domain_id, ordername);


CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL,
  account               VARCHAR(40) NOT NULL,
  PRIMARY KEY (ip, nameserver)
) Engine=InnoDB;


CREATE TABLE comments (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) NOT NULL,
  comment               VARCHAR(64000) NOT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX comments_domain_id_idx ON comments (domain_id);
CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);


CREATE TABLE domainmetadata (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  kind                  VARCHAR(32),
  content               TEXT,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);


CREATE TABLE cryptokeys (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  flags                 INT NOT NULL,
  active                BOOL,
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB;

CREATE INDEX domainidindex ON cryptokeys(domain_id);


CREATE TABLE tsigkeys (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);

CREATE TABLE connect_log (
  id                    INT AUTO_INCREMENT,
  address               VARCHAR(64000) DEFAULT NULL,
  num_connect           INT NOT NULL DEFAULT 0,
  last_connect          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);"

  ##############################
  chmod 644 /etc/pdns/pdns.conf
  #append to /etc/pdns/pdns.config
  echo "launch=gmysql
gmysql-host=localhost
gmysql-user=$MYSQL_USER
gmysql-dbname=powerdns
gmysql-password=$MYSQL_PASS" >> /etc/pdns/pdns.conf
  ##############################
  systemctl enable pdns.service
  systemctl start pdns.service

  pdnsutil create-zone test.com r1.test.com
  sh ./create_records.sh 0 1000

  #echo whoisd.service to /etc/systemd/system/whoisd.service
  echo "#!/bin/sh
  #

  [Unit]
  Description=whoisd service
  After=syslog.target

  [Service]
  Type=simple
  ExecStart=/bin/python "$PWD"/whois_server.py
  StandardOutput=syslog
  StandardError=syslog
  Restart=on-abort
  KillMode=process

  ExecStop=/bing/rm -rf /var/run/whoisd.sock

  [Install]
  WantedBy=multi-user.target
  " > /etc/systemd/system/whoisd.service
  chmod 644 /etc/systemd/system/whoisd.service
  systemctl enable whoisd.service
  systemctl start whoisd
  ;;
  -u)
  #mySQL is euqal to "name rNNN.test.com"
  number=$(mysql -u $MYSQL_USER -p$MYSQL_PASS powerdns -se "SELECT name FROM records WHERE id=(SELECT max(id) FROM records);" | sed 's/[^0-9]*//g')
  sh ./create_records.sh $((number+1)) $((number+100))
  ;;
  -m)
  #TODO: THIS
  #check for $file, if its there move it $oldfile
  if [ ! -f $PWD/axfr_c.txt ]; then
    echo "No Previous zone transfers, no other change possible. Writing new AXFR Transfer"
    echo $(dig @localhost test.com AXFR) > $PWD/axfr_c.txt
  else
    mv $PWD/axfr_c.txt $PWD/axfr.old
    echo $(dig @localhost test.com AXFR) > $PWD/axfr_c.txt
    axfr_len=$(cat $PWD/axfr_c.txt | wc -c)
    old_len=$(cat $PWD/axfr.old | wc -c)
    difference=$(expr $axfr_len - $old_len)
    percent=$(echo "100 * $difference / $old_len" | bc)
    if [ $percent -gt 15 ]; then
      echo "A change in the AXFR of $percent percent has occured since last run. "
    else
      echo "A change of less than 15% has occured "
    fi
  fi
  ;;
  *)
  echo "$1 is not a proper argument, use -i -u or -m"
  ;;
esac
#clear enviromental variables from path
MYSQL_USER=''
MYSQL_PASS=''
