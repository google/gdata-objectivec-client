#!/usr/bin/python
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""A simple server for testing the Objective-C GData Framework

This http server is for use by GDataServiceTest.m in testing
both authentication and object retrieval.

Requests to the path /accounts/ClientLogin are assumed to be
for login; other requests are for object retrieval
"""

import string
import cgi
import time
import os
import sys
import re
import mimetypes
import socket
from BaseHTTPServer import BaseHTTPRequestHandler
from BaseHTTPServer import HTTPServer
from optparse import OptionParser

class ServerTimeoutException(Exception):
  pass


class HTTPTimeoutServer(HTTPServer):
  
  """HTTP server for testing network requests.
  
  This server will throw an exception if it receives no connections for
  several minutes. We use this to ensure that the server will be cleaned
  up if something goes wrong during the unit testing.
  """

  def get_request(self):
    self.socket.settimeout(120.0)
    result = None
    while result is None:
      try:
        result = self.socket.accept()
      except socket.timeout:
        raise ServerTimeoutException
    result[0].settimeout(None)
    return result


class SimpleServer(BaseHTTPRequestHandler):

  """HTTP request handler for testing GData network requests.
  
  This is an implementation of a request handler for BaseHTTPServer,
  specifically designed for GData service code usage.
  
  Normal requests for GET/POST/PUT simply retrieve the file from the
  supplied path, starting in the current directory.  A cookie called
  TestCookie is set by the response header, with the value of the filename
  requested.
  
  DELETE requests always succeed.
  
  Appending ?status=n results in a failure with status value n.
  
  Paths ending in .auth have the .auth extension stripped, and must have
  an authorization header of "GoogleLogin auth=GoodAuthToken" to succeed.
  
  Paths ending in .authsub have the .authsub extension stripped, and must have
  an authorization header of "AuthSub token=GoodAuthSubToken" to succeed.
  
  Paths ending in .authwww have the .authwww extension stripped, and must have
  an authorization header for GoodWWWUser:GoodWWWPassword to succeed.
  
  Successful results have a Last-Modified header set; if that header's value
  ("thursday") is supplied in a request's "If-Modified-Since" header, the 
  result is 304 (Not Modified).
  
  Requests to /accounts/ClientLogin will fail if supplied with a body
  containing Passwd=bad. If they contain logintoken and logincaptcha values,
  those must be logintoken=CapToken&logincaptch=good to succeed.
  """

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
    modifiedDate = "thursday" # clients should treat dates as opaque, generally
    
    # auth queries and some GData queries include post data
    postLength = int(self.headers.getheader("Content-Length", "0"));
    if postLength > 0:
      postString = self.rfile.read(postLength)
      
    ifModifiedSince = self.headers.getheader("If-Modified-Since", "");
    
    # retrieve the auth header
    authorization = self.headers.getheader("Authorization", "")
    
    # require basic auth if the file path ends with the string ".authwww"
    # GoodWWWUser:GoodWWWPassword is base64 R29vZFdXV1VzZXI6R29vZFdXV1Bhc3N3b3Jk
    if self.path.endswith(".authwww"):
      if authorization != "Basic R29vZFdXV1VzZXI6R29vZFdXV1Bhc3N3b3Jk":
        self.send_response(401)
        self.send_header('WWW-Authenticate', "Basic realm='testrealm'")
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        return
      self.path = self.path[:-8] # remove the .authwww at the end

    # require Google auth if the file path ends with the string ".auth"
    # or ".authsub"
    if self.path.endswith(".auth"):
      if authorization != "GoogleLogin auth=GoodAuthToken":
        self.send_error(401,"Unauthorized: %s" % self.path)
        return
      self.path = self.path[:-5] # remove the .auth at the end
    if self.path.endswith(".authsub"):
      if authorization != "AuthSub token=GoodAuthSubToken":
        self.send_error(401,"Unauthorized: %s" % self.path)
        return
      self.path = self.path[:-8] # remove the .authsub at the end
    
    # chunked (resumable) upload testing
    if self.path.endswith(".location"):
      # return a location header containing the request path with
      # the ".location" suffix changed to ".upload"
      host = self.headers.getheader("Host", "");
      fullLocation = "http://%s%s.upload" % (host, self.path[:-9])
      
      self.send_response(200)
      self.send_header("Location", fullLocation)
      self.end_headers()
      return
    
    if self.path.endswith(".upload"):
      # if the contentRange indicates this is a middle chunk,
      # return status 308 with a Range header; otherwise, strip
      # the ".upload" and continue to return the file
      #
      # contentRange is like
      #  Content-Range: bytes 0-49999/135681
      # or
      #  Content-Range: bytes */135681
      contentRange = self.headers.getheader("Content-Range", "");
      searchResult = re.search("(bytes \*/)([0-9]+)",
        contentRange)
      if searchResult:
        # this is a query for where to resume; we'll arbitrarily resume at
        # half the total length of the upload
        totalToUpload = int(searchResult.group(2))
        resumeLocation = totalToUpload / 2
        self.send_response(308)
        self.send_header("Range", "bytes=0-%d" % resumeLocation)
        self.end_headers()
        return
        
      searchResult = re.search("(bytes )([0-9]+)(-)([0-9]+)(/)([0-9]+)",
        contentRange)
      if searchResult:
        endRange = int(searchResult.group(4))
        totalToUpload = int(searchResult.group(6))
        if (endRange + 1) < totalToUpload:
          # this is a middle chunk, so send a 308 status to ask for more chunks
          self.send_response(308)
          self.send_header("Range", "bytes=0-" + searchResult.group(4))
          self.end_headers()
          return
        else:
          self.path = self.path[:-7] # remove the .upload at the end
    
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
            resultString = ("Error=CaptchaRequired\nCaptchaToken=CapToken\n"
              "CaptchaUrl=CapUrl\n")
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
          
        # queries that have something like "?statusxml=456" should fail with the
        # status code and structured XML response
        searchResult = re.search("(statusxml=)([0-9]+)", self.path)
        if searchResult:
          status = searchResult.group(2)
          self.send_response(int(status))
          self.send_header("Content-type",
            "application/vnd.google.gdata.error+xml")
          self.end_headers()
          resultString = ("<errors xmlns='http://schemas.google.com/g/2005'>"
            "<error><domain>GData</domain><code>code_%s</code>"
            "<internalReason>forced status error on path %s</internalReason>"
            "<extendedHelp>http://help.com</extendedHelp>"
            "<sendReport>http://report.com</sendReport></error>"
            "</errors>" % (status, self.path))
          self.wfile.write(resultString)
          return
          
        # if the client gave us back our modified date, then say there's no
        # change in the response
        if ifModifiedSince == modifiedDate:
          self.send_response(304) # Not Modified
          return
          
        else:
          #
          # it's an object fetch; read and return the XML file
          #
          f = open("." + self.path)
          resultString = f.read()
          f.close()
          resultStatus = 200
          fileTypeInfo = mimetypes.guess_type("." + self.path)
          headerType = fileTypeInfo[0] # first part of the tuple is mime type
        
      self.send_response(resultStatus)
      self.send_header("Content-type", headerType)
      self.send_header("Last-Modified", modifiedDate)
      
      # set TestCookie to equal the file name requested
      cookieValue = os.path.basename("." + self.path)
      self.send_header('Set-Cookie', 'TestCookie=%s' % cookieValue)
      
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
    server = HTTPTimeoutServer(("127.0.0.1", options.port), SimpleServer)
    sys.stdout.write("started GDataTestServer.py...");
    sys.stdout.flush();
    server.serve_forever()
  except KeyboardInterrupt:
    print "^C received, shutting down server"
    server.socket.close()
  except ServerTimeoutException:
    print "Too long since the last request, shutting down server"
    server.socket.close()

if __name__ == "__main__":
  main()

