#!/usr/bin/env ruby

class Array
  def to_csv delimiter=';'
    ms=map.map(&:to_h)
    ks=ms.map(&:keys).flatten.uniq
    h="#"+ks.join(delimiter)+"\n"
    csv=(ms.map do |m|
      m.values_at(*ks).join delimiter
    end.join("\n"))
    h+csv
  end
end

Dir.chdir(File.dirname __FILE__)
$:.unshift 'lib'

require 'pry'
require 'bond'
require 'savon'
require 'w4n/filter'
require 'w4n/cli'
#require 'pry/bond/default'
#Bond.config[:readline]=Pry::BondCompleter::NoopReadline
#Bond::M.load_file './completion.rb'

class Hash
  def sym_keys
    each_with_object({}) do |(k,v),o|
      o[k.to_sym]=v
    end
  end
end
options={host: 'localhost', user: 'admin', password: 'changeme'}
options.merge!(YAML.load_file('./config.yml').sym_keys)

[Filter].each do |c|
  c.class_eval "
    def methods
      super - Object.methods
    end
  "
end

Filter.client=Savon.client(log: options[:xml]) do |g|
  g.wsdl "http://#{options[:host]}:58080/APG-WS/wsapi/db?wsdl"
  g.basic_auth options[:user],options[:password]
  g.log false
end

Cli.start
