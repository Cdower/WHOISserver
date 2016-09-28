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
import MySQLdb

class HandleQueries():
     def __init__(self, mysql_port):
         self.db=_mysql.connect(host='localhost', user='powerdns', passwd='tecmint123', db='powerdns', port=mysql_port)

    def name_query(self, query):
        c = self.db.cursor()
        to_return = c.execute("""SELECT * FROM records WHERE name LIKE  %s""", (query,))
        print c.fetchall()


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
