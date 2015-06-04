#!/usr/bin/env ruby

Dir.chdir(File.dirname __FILE__)
$:.unshift 'lib'

require 'w4n/pre'
require 'pry'
require 'yaml'
require 'savon'
require 'optparse'
require 'w4n/additions'
require 'w4n/filter'
require 'w4n/cli'

options={host: 'localhost', user: 'admin', password: 'changeme', log: false, file: nil}
options.merge!(YAML.load_file('./config.yml').sym_keys)

OptionParser.new do |opts|
  opts.banner = "Usage: mnrcli.rb [options]"

  opts.on("-h", "--host [hostname]", String, "Web-Server host") do |h|
    options[:host] = h
  end
  opts.on("-u", "--user [username]", String, "Web-Service username") do |u|
    options[:user] = u
  end
  opts.on("-p", "--password [*****]", String, "Web-Service password") do |p|
    options[:password] = p
  end
  opts.on("-l", "--log", "Log XML requests") do |l|
    options[:log] = true
  end
  opts.on("-f", "--file [file]",String,"Read commands from file") do |f|
    options[:file] = f
  end
end.parse!

Filter.setup options.slice :host,:user,:password,:log

Cli.start file: options[:file]
