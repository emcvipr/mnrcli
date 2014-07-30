require 'set'
require 'w4n/machine'

class Filter < Set
  @@offset=3600
  @@prefilter=nil
  @@filter=nil
  def self.client= c
    @@client=c
  end
  def self.prefilter= p
    @@prefilter=p
  end
  def self.set_filter s
    @@filter=s
  end
  def self.reset_filter!
    @@filter=nil
  end
  def self.offset
    @@offset
  end
  def self.offset= v
    @@offset=v
  end
  def [] *x
    self.class.new self+x
  end
  def to_filter_string
    @fs||=self.to_s.encode xml: :text
  end
  def to_s
    self['#APG:ALL'][@@prefilter][@@filter].map(&:to_s).reject(&:empty?).inject do |x,y| "(#{x}) & (#{y})" end || ''
  end
  def create_message **opts
    m = ["<tns:filter>#{to_filter_string}</tns:filter>"]
    m+=(opts[:props]||[]).map do |p|
      "<tns:property>#{p}</tns:property>"
    end
    if opts[:ts]
      tim=Time.now.to_i
      m << "<tns:start-timestamp>#{tim-@@offset}</tns:start-timestamp>"
      m << "<tns:end-timestamp>#{tim+@@offset}</tns:end-timestamp>"
    end
    m.join "\n"
  end
  def count
    @@client.call(:get_object_count,message:create_message).xpath('//ns2:count').first.text.to_i
  end
  def available_properties
    @@client.call(:get_available_properties,message:create_message).xpath('//ns2:property/@name').map &:value
  end
  def get_property prop
    get_distinct(prop).map(&prop)
  end
  def get_properties *props
    get_distinct(*props).map do |m| props.map do |p| m[p] end end
  end
  def get_all
    props=available_properties
    get *props
  end
  def get_object_data **x
    xml=@@client.call(:get_object_data,message:create_message(ts:true)).to_xml
    Watch4Net::SAX::GetObjectData.parse xml,Hash#,props
  end
  def get_distinct *props
    xml=@@client.call(:get_distinct_property_records,message:create_message(props:props)).to_xml
    Watch4Net::SAX::GetDistinctPropertyRecords.parse xml,Array,props
  end
  def get *props
    want_last_rv=props.delete :last_rv
    xml=@@client.call(:get_object_properties,message:create_message(props:props)).to_xml
    mets=Watch4Net::SAX::GetObjectProperties.parse xml,Array,props
    if want_last_rv
      vals=get_object_data
      mets.each do |m|
        v=vals[m.id]
        m.value=v ? v.last : nil
      end
    end
    mets
  end
  def value_per *expansion
    self.get(*expansion,:last_rv).map do |m|
      [m.values_at(*expansion),m.value]
    end.to_h
  end
end
