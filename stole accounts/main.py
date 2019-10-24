#!/usr/bin/python
# -*- coding: utf-8 -*-
import json
import os
import sys
import cgi
from datetime import datetime
from StringIO import StringIO<html>

#====================================================================
#func
def ln():
    print "<br>"
#====================================================================
#html
print "Content-type: text/html\n\n"
print """
    <head>
    <style>
    body{
    background:black;
    color:white
    }
    </style>
    </head>
    """
#==================================
#html body
print "<body>"
#====================================================================
#main
#==================================
#have QUERY?
query_string_key = 'QUERY_STRING'
if query_string_key in os.environ:#{
    query = cgi.parse_qs(os.environ[query_string_key])
#}
else:#{
    query = {}
#}
print query;ln()

print "</body>"
print "</html>"
