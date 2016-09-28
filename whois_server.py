#!/usr/bin/env python

import ConfigParser
config= ConfigParser.RawConfigParser();
config.read("./whois_server.conf")

import syslog
syslog.openlog('Whois_Server_Queries', )

host = config.get('whois_server', 'host')
port = int(config.get('whois_server', 'port'))
mysql_port = int(config.get('whois_server', 'mysql_db'))
import SocketServer

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
        #url = "%%"+url
        return_string = ''
        cursor = self.db.cursor()
        query = ("SELECT * FROM records WHERE name LIKE %s")
        cursor.execute(query, ("%%"+url,))
        for curse in cursor:
            return_string += 'Server Name: ' + curse[2] + '\nIP Address: ' + curse[4] + '\n\n'
        return return_string #return string to send

    def end_queries(self):
        self.db.close()


class WhoisHandler(SocketServer.BaseRequestHandler):
    """
    Handles whois requests
    """
    def handle(self):
        syslog.syslog(syslog.LOG_INFO, self.client_address[0] + ' is connected') #log client connections

        queries = 0
        while 1:
            query = self.request.recv(1024).strip()
            if query == '':
                #log number of queries  from client
                break
            ip = None
            print self.client_address[0] + ': ' + query
            queries += 1
            try:
                ip = IPy.IP(query)
            except:
                pass
            if ip:
                #response = query_ip(ip)
                response = 'response: ' + ip
            else:
                #response = query_url(query)
                response = 'response: ' + query
            self.request.sendall(response + '\n\n')
        #log self.client_address[0] #log to redis?
        #setup query

server = SocketServer.ThreadingTCPServer((host, port), WhoisHandler)
server.serve_forever()
