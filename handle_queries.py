#!/usr/bin/python

import IPy
import mysql.connector

class HandleQueries():
    def __init__(self, mysql_port):
        db_config = {
            'user': 'powerdns',
            'password': 'tecmint123',
            'host': 'localhost',
            'database': 'powerdns',
            'port': mysql_port
        }
        self.db= mysql.connector.connect(**db_config)

    def name_query(self, url):
        return_string = ''
        cursor = self.db.cursor()
        query = ("SELECT * FROM records WHERE name LIKE %s")
        cursor.execute(query, (url,))
        for (domain_id, name, content, ttl) in cursor:
            print ('{}: {}, domain_id:{} ttl:{}'.format(name, content, domain_id, ttl))
        #return return_string #return string to send

    def end_queries(self):
        self.db.close()


if __name__ == "__main__":
    queryH = HandleQueries(3306)
    print queryH.name_query("test.com")
