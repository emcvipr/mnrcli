#!/usr/bin/env ruby
require 'pry'
require 'savon'

Dir.chdir(File.dirname __FILE__)
$:.unshift 'lib'
require 'w4n/filter'

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

#options = {host: 'lgloz116.lss.emc.com' , user: 'admin', password: 'changeme'}
Filter.client=Savon.client(log: options[:xml]) do |g|
  g.wsdl "http://#{options[:host]}:58080/APG-WS/wsapi/db?wsdl"
  g.basic_auth options[:user],options[:password]
  g.log false
end

Pry.config


Pry.start nil, prompt_name: 'mnrcli'

