require 'optparse'
require_relative 'testcases'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: optparse1.rb [options] file1 file2 ..."

  # Define the options, and what they do
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end

  options[:config] = false
  opts.on( '-c', '--config FILE', 'Use named config file. Default is uji.cfg.' ) do|config|
    options[:config] = config
  end

  options[:logfile] = nil
  opts.on( '-l', '--logfile FILE', 'Output results to logfile. Default is stdout.' ) do|file|
    options[:logfile] = file
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

filename = options[:config]
unless filename
  filename = "uji.cfg"
end

config = Testcases.new(filename, options[:verbose])

config.runtests