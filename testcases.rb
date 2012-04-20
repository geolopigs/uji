require 'yaml'
require_relative 'testcase'

class Testcases

  def initialize(filename, verbose)
    @verbose = verbose
    @filename = filename
    @testcase_list = Array.new
    first = true

    File.open(filename) do |yf|
      YAML.each_document( yf ) do |ydoc|
        if first
          @globalparamhash = ydoc
          first = false
        else
          @testcase_list << Testcase.new(ydoc, verbose)
        end
      end
    end
  end

  def runtests
    # validate that a host has been specified
    raise ArgumentError.new("Unable to continue tests due to missing host") unless @globalparamhash['host']

    testnum = 1

    @testcase_list.each do |tc|
      begin
        puts "Test case: " + testnum.to_s
        if tc.runtest(@globalparamhash['host'])
          puts "Test passed"
        else
          puts "Test failed"
        end
        testnum = testnum+1
        puts "----------"
      rescue Exception => e
        puts e.message
      end
    end
  end

end