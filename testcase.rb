# Testcase expects three required parameters:
#  1. method (GET, POST, etc)
#  2. status (the expected response from the server, e.g. 200 or 406)
#  3. response (the body of the response from the server)
# There are also two optional params:
#  1. path (the url path, e.g. /foo/bar)
#  2. headers (the list of headers to be passed as part of the query)
#  3. body (body of the request made to the server)

require 'net/http'
require 'json'

class Testcase

  @@state = {}

  def initialize(paramhash, verbose)
    @paramhash = paramhash
    @verbose = verbose
  end

  def runtest(host)
    begin
      fullpath = host
      if @paramhash['path']
        fullpath += @paramhash['path']
      end

      if @verbose
        puts "Full path: " + fullpath
      end

      method = @paramhash['method']
      raise ArgumentError.new("Unable to continue tests due to missing http method") unless method
      if method == 'GET'
        runtestget(fullpath)
      elsif method == 'POST'
        runtestpost(fullpath, false)
      elsif method == 'PUT'
        runtestpost(fullpath, true)
      end
    rescue Exception => e
      puts e.message
    end
  end

  def checkstatus(res)
    result = false
    begin
      expected_status = @paramhash['status']
      raise ArgumentError.new("No expected response status for this test specified") unless expected_status

      result = (res.code <=> expected_status.to_s)

      if @verbose
        output = "Checking for status #{expected_status} - "
        if result
          output += "Matched!"
        else
          output += "Not Matched! - Got " + res.code + " instead"
        end
        puts output
      end
    rescue Exception => e
      puts e.message
    end

    # response code from server matches would return true, false otherwise.
    result
  end

  def checkresponse(res)
    result = false
    begin
      expected_response = JSON.parse(@paramhash['response'])
      raise ArgumentError.new("No expected response status for this test specified") unless expected_response

      responsebody = JSON.parse(res.body)
      result = (responsebody == expected_response)

      if @verbose
        puts responsebody.to_s
        puts expected_response.to_s
        if result
          puts "Response body matched"
        else
          errormsg = "Incorrect response body received: " + responsebody.to_s
          puts errormsg
        end
      end

    rescue Exception => e
        puts e.message
    end
    result
  end

  def addheaders(request)
    # Add standard headers
    request["Accept"] = "application/json"
    request["Content-type"] = "application/json"

    # Add other headers
    if @paramhash['headers']
      headers = @paramhash['headers']
      headers = headers[1..-2].split(',').collect! {|n| n.to_s.strip}
      for header in headers
        pair = header.split(":")
        request[pair[0].strip] = pair[1].strip
      end
    end
  end

  def runtestget(fullpath)
    begin

      if @verbose
        puts "Running GET test...."
      end

      # Creating request
      uri = URI.parse(fullpath)
      request = Net::HTTP::Get.new(uri.path)
      addheaders(request)

      # Make the actual rest call
      response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }

      checkstatus(response) and checkresponse(response)

    rescue Exception => e
      puts e.message
    end
  end

  def runtestpost(fullpath, useput)
    begin

      if @verbose
        puts "Running POST test...."
      end

      uri = URI.parse(fullpath)
      data = ""
      if @paramhash['body']
        data = @paramhash['body']
      end

      if @verbose
        puts "Body: " + data
      end

      # Creating the request
      if useput
        request = Net::HTTP::Put.new(uri.path)
      else
        request = Net::HTTP::Post.new(uri.path)
      end
      addheaders(request)
      request.body = data

      # Make the actual rest call
      response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }

      # Validate response
      checkstatus(response) and checkresponse(response)

    rescue Exception => e
      puts e.message
    end
  end

end