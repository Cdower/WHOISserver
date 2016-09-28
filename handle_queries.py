#!/usr/bin/python

import IPy
import MySQLdb

class HandleQueries():
    def __init__(self, mysql_port):
        self.db=_mysql.connect(host='localhost', user='powerdns', passwd='tecmint123', db='powerdns', port=mysql_port)

    def name_query(self, query):
        c = self.db.cursor()
        to_return = c.execute("""SELECT * FROM records WHERE name LIKE  %s""", (query,))
        return c.fetchall()

if __name__ == "__main__":
    queryH = HandleQueries(3306)
    print queryH.name_query("test.com")
