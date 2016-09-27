#!/usr/bin/env python

import ConfigParser
config= ConfigParser.RawConfigParser();
config.read("./whois_server.conf")

import syslog
syslog.openlog('Whois_Server_Queries', )

host = config.get('whois_server', 'host')
port = int(config.get('whois_server', 'port'))
import SocketServer

import IPy

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
            self.request.send(response + '\r\n\r\n\n')
        #log self.client_address[0] #log to redis?
        #setup query

server = SocketServer.ThreadingTCPServer((host, port), WhoisHandler)
server.serve_forever()
