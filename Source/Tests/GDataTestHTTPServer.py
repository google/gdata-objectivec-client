#!/usr/bin/python2.3
#
#  A simple server for testing the Objective-C GData Framework

import string
import cgi
import time
import os
import sys
import re
from BaseHTTPServer import BaseHTTPRequestHandler
from BaseHTTPServer import HTTPServer
from optparse import OptionParser

class SimpleServer(BaseHTTPRequestHandler):
  # This http server is for use by GDataServiceTest.m in testing
  # both authentication and object retrieval.
  #
  # Requests to the path /accounts/ClientLogin are assumed to be
  # for login; other requests are for object retrieval
  def do_GET(self):
    self.doAllRequests()

  def do_POST(self):
    self.doAllRequests()

  def do_PUT(self):
    self.doAllRequests()
  
  def do_DELETE(self):
    self.doAllRequests()
  
  def doAllRequests(self):
    # This method handles all expected incoming requests
    #
    # Requests to path /accounts/ClientLogin are assumed to be for signing in
    #
    # Other paths are for retrieving a local xml file.  An .auth appended
    # to an xml file path will require authentication (meaning the Authorization
    # header must be present with the value "GoogleLogin auth=GoodAuthToken".)
    # Delete commands succeed but return no data.
    #
    # GData override headers are supported.
    #
    # Any auth password is valid except "bad", which will fail, and "captcha",
    # which will fail unless the authentication request's post string includes 
    # "logintoken=CapToken&logincaptcha=good"
    
    # We will use a readable default result string since it should never show up
    # in output
    resultString = "default GDataTestServer result\n";
    resultStatus = 0
    headerType = "text/plain"
    postString = ""
    
    # auth queries and some GData queries include post data
    postLength = int(self.headers.getheader("Content-Length", "0"));
    if postLength > 0:
      postString = self.rfile.read(postLength)
      
    # retrieve the auth header; require it if the file path ends 
    # with the string ".auth"
    authorization = self.headers.getheader("Authorization", "")
    if self.path.endswith(".auth"):
      if authorization != "GoogleLogin auth=GoodAuthToken":
        self.send_error(401,"Unauthorized: %s" % self.path)
        return
      self.path = self.path[:-5] # remove the .auth at the end
    
    overrideHeader = self.headers.getheader("X-HTTP-Method-Override", "")
    httpCommand = self.command
    if httpCommand == "POST" and len(overrideHeader) > 0:
      httpCommand = overrideHeader
    
    try:
      if self.path.endswith("/accounts/ClientLogin"):
        #
        # it's a sign-in attempt; it's good unless the password is "bad" or
        # "captcha"
        #
        
        # use regular expression to find the password
        password = ""
        searchResult = re.search("(Passwd=)([^&\n]*)", postString)
        if searchResult:
          password = searchResult.group(2)
        
        if password == "bad":
          resultString = "Error=BadAuthentication\n"
          resultStatus = 403

        elif password == "captcha":
          logintoken = ""
          logincaptcha = ""
          
          # use regular expressions to find the captcha token and answer
          searchResult = re.search("(logintoken=)([^&\n]*)", postString);
          if searchResult:
            logintoken = searchResult.group(2)
            
          searchResult = re.search("(logincaptcha=)([^&\n]*)", postString);
          if searchResult:
            logincaptcha = searchResult.group(2)
          
          # if the captcha token is "CapToken" and the answer is "good"
          # then it's a valid sign in
          if (logintoken == "CapToken") and (logincaptcha == "good"):
            resultString = "SID=GoodSID\nLSID=GoodLSID\nAuth=GoodAuthToken\n"
            resultStatus = 200
          else:
            # incorrect captcha token or answer provided
            resultString = "Error=CaptchaRequired\nCaptchaToken=CapToken\nCaptchaUrl=CapUrl\n"
            resultStatus = 403

        else:
          # valid username/password
          resultString = "SID=GoodSID\nLSID=GoodLSID\nAuth=GoodAuthToken\n"
          resultStatus = 200
          
      elif httpCommand == "DELETE":
        #
        # it's an object delete; read and return empty data
        #
        resultString = ""
        resultStatus = 200
        headerType = "text/plain"
        
      else:
        # queries that have something like "?status=456" should fail with the
        # status code
        searchResult = re.search("(status=)([0-9]+)", self.path)
        if searchResult:
          status = searchResult.group(2)
          self.send_error(int(status),
            "Test HTTP server status parameter: %s" % self.path)
          return

        else:
          #
          # it's an object fetch; read and return the XML file
          #
          f = open("." + self.path)
          resultString = f.read()
          f.close()
          resultStatus = 200
          headerType = "application/atom+xml"
        
      self.send_response(resultStatus)
      self.send_header("Content-type", headerType)
      self.end_headers()
      self.wfile.write(resultString)

    except IOError:
      self.send_error(404,"File Not Found: %s" % self.path)
      
def main():
  try:
    parser = OptionParser()
    parser.add_option("-p", "--port", dest="port", help="Port to run server on",
                      type="int", default="80")
    parser.add_option("-r", "--root", dest="root", help="Where to root server",
                      default=".")
    (options, args) = parser.parse_args()
    os.chdir(options.root)
    server = HTTPServer(("127.0.0.1", options.port), SimpleServer)
    sys.stdout.write("started GDataTestServer.py...");
    sys.stdout.flush();
    server.serve_forever()
  except KeyboardInterrupt:
    print "^C received, shutting down server"
    server.socket.close()

if __name__ == "__main__":
  main()

