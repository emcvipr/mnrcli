require 'set'
require 'w4n/machine'

class Filter < Set
  class << self
    attr_accessor :prefilter,:offset,:server,:filter,:client
    def setup **options
      self.client=Savon.client(log: options[:xml]) do |g|
        g.wsdl "http://#{options[:host]}:58080/APG-WS/wsapi/db?wsdl"
        g.basic_auth options[:user],options[:password]
        g.log false
      end
      self.server=options[:host]
    end
  end
  self.offset=3600
  def [] *x
    self.class.new self+x
  end
  def to_filter_string
    @fs||=self.to_s.encode xml: :text
  end
  def to_s
    self['#APG:ALL'][self.class.prefilter][self.class.filter].map(&:to_s).reject(&:empty?).inject do |x,y| "(#{x}) & (#{y})" end || ''
  end
  def create_message **opts
    m = ["<tns:filter>#{to_filter_string}</tns:filter>"]
    m+=(opts[:props]||[]).map do |p|
      "<tns:property>#{p}</tns:property>"
    end
    if opts[:ts]
      tim=Time.now.to_i
      m << "<tns:start-timestamp>#{tim-self.class.offset}</tns:start-timestamp>"
      m << "<tns:end-timestamp>#{tim+self.class.offset}</tns:end-timestamp>"
    end
    m.join "\n"
  end
  #Count number of metrics
  def count
    self.class.client.call(:get_object_count,message:create_message).xpath('//ns2:count').first.text.to_i
  end
  def available_properties **opts
    p=opts[:description] ? proc do |p| [p[:name].to_sym,p.text] end : proc do |p| p[:name] end
    self.class.client.call(:get_available_properties,message:create_message).xpath('//ns2:property').map &p
  end
  def get_property prop
    get_distinct(prop).map(&prop)
  end
  def get_properties *props
    get_distinct(*props).map do |m| props.map do |p| m[p] end end
  end
  #Get all the properties & their values
  def get_all
    props=available_properties
    get *props
  end
  def get_object_data **x
    xml=self.class.client.call(:get_object_data,message:create_message(ts:true)).to_xml
    Watch4Net::SAX::GetObjectData.parse xml,Hash#,props
  end
  def get_distinct *props
    xml=self.class.client.call(:get_distinct_property_records,message:create_message(props:props)).to_xml
    Watch4Net::SAX::GetDistinctPropertyRecords.parse xml,Array,props
  end
  def get *props
    want_last_rv=props.delete :last_rv
    xml=self.class.client.call(:get_object_properties,message:create_message(props:props)).to_xml
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
  def count_per *expansion
    self.get(*expansion).each_with_object(Hash.new 0) do |m,o|
      o[m.values_at(*expansion)]+=1
    end
  end
end
