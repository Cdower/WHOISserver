#!/usr/bin/env python

import ConfigParser
config= ConfigParser.RawConfigParser();
config.read("./whois_server.conf")

import syslog
syslog.openlog('Whois_Server_Queries', )

host = config.get('whois_server', 'host')
port = int(config.get('whois_server', 'port'))
import SocketServer

class WhoisHandler(SocketServer.BaseRequestHandler):
    """
    Handles whois requests
    """
    def handle(self):
        syslog.syslog(syslog.LOG_INFO, self.client_address[0] + ' is connected') #log client connections
        while 1:
            query = self.request.recv(1024).strip()
            if query == '':
                break
            print self.client_address[0] + ': ' + query
        #log self.client_address[0] #log to redis?
        #setup query



server = SocketServer.ThreadingTCPServer((host, port), WhoisHandler)
server.serve_forever()
