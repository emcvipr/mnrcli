require 'pry/input_completer'
require 'w4n/commands'

module Property
  Symbol.include self
  def values
    filter.get_property self
  end
  def count
    filter.count
  end
  def description
    filter.available_properties(description: true).to_h[self]
  end
  private
  def filter
    Filter[self.to_s]
  end
end

class Pry::W4NCompleter < Pry::InputCompleter
  def self.meths klass
    klass.instance_methods(false).map(&:to_s)
  end
  FILTER_METHODS=meths Filter
  PROP_METHODS=meths Property
  def call str, options={}
    lb=@input.line_buffer
    if ma=lb.match(/^([^"]*"[^"]*"[^"]*)*"([^"]*)$/)
      ma[2].complete
    elsif ma=lb.match(/"(?<filter>[^"]*)".+?get(_distinct)?.*:(?<prop>[a-z]*)$/)
      ma['filter'].available_properties.grep(/^#{ma['prop']}/).map do |x| ":#{x}" end
    elsif ma=lb.match(/"(?<filter>[^"]*)"\.(?<meth>[a-z_]*)$/)
      FILTER_METHODS.grep(/^#{ma['meth']}/).map do |x| ".#{x}" end
    elsif ma=lb.match(/:(?<prop>[a-z]*)$/)
      ma['prop'].complete.map do |x| ":#{x}" end
    elsif ma=str.match(/(?<prop>:[a-z]+)\.(?<meth>[a-z_]*)$/)
      PROP_METHODS.grep(/^#{ma['meth']}/).map do |x| "#{ma['prop']}.#{x}" end
    else
      super str,options
    end
  end
end

module Enumerable
  def map_find ifnone=nil,&block
    self.each do |*p|
      if x=block.call(*p)
        return x
      end
    end
    ifnone
  end
end

module StringAdditions
  String.prepend self
  DISPATCHER=[
    /(?<prop>[a-z]+)\s*==?\s*'(?<val>[^']*)$/, proc do |ma|
      Filter["#{ma['prop']}='#{ma['val']}%'"].get_property(ma['prop'].to_sym)
    end,
    /(?<prop>[a-z]+)$/, proc do |ma|
      Filter[].available_properties.select do |p| p.match /^#{ma['prop']}/ end
    end,
    /['a-z]*\s*$/, proc do
      %w{& | ( )}
    end
    #/([a-z]+)\s*/,          proc do |ma| %w{= & |} end,
    #/([a-z]+)\s*=/,         proc do |ma| %w{= '} end,
    #/([a-z]+)\s*==/,        proc do |ma| %w{'} end,
  ]
  def complete
    DISPATCHER.each_slice(2).map_find([]) do |p,b|
      ma=self.match(p) and b.call(ma)
    end
  end
  def count x=nil
    x ? super(x) : Filter[self].count
  end
  def method_missing name,*args,&block
    Filter[self].send name,*args,&block
  end
end
