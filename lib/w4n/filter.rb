require 'set'
require 'w4n/machine'

class Filter < Set
  module TimeRange
    attr_reader :offset,:from,:until
    def offset= x
      @offset,@from,@until=x,nil,nil
    end
    def from= x
      @until||=nil
      @from,@offset=x,nil
    end
    def until= x
      @from||=nil
      @until,@offset=x,nil
    end
    def reset_range
      @offset,@from,@until=nil,nil,nil
    end
    def current_range offset: nil, from: nil, **opts
      # until is a reserved keyword, local var could be obtained with:
      #   til=binding.local_variable_get(:until)
      # but we support 2.0, so we have to use **opts :'(
      til=opts.delete(:until)||@until
      raise ArgumentError,sprintf("unknown keyword%s: %s",(opts.size==1?'':'s'),opts.keys.join(', ')) unless opts.empty?
      raise ArgumentError,"offset and from/until are mutually exclusive" if offset and (from or til)
      offset||=@offset||3600
      from||=@from
      if from
        til||= Time.now+3600
        [to_ts(from),to_ts(til)]
      else
        tim=Time.now.to_i
        [tim-offset,tim+3600]
      end
    end
    private
    def to_ts x
      Date===x ? x.to_time.to_i : x.to_i
    end
  end
  class << self
    include TimeRange
    attr_accessor :prefilter,:server,:filter,:client
    def setup host: 'localhost', user: 'admin', password: 'changeme', log: nil, timeout: 120
      log=self.client.globals[:log] if log.nil? and self.client
      self.client=Savon.client(
        log: log,
        wsdl: "http://#{host}:58080/APG-WS/wsapi/db?wsdl",
        basic_auth: [user,password],
        follow_redirects: true,
        ssl_verify_mode: :none,
        read_timeout: timeout,
        pretty_print_xml: log,
      )
      self.server=host
    end
  end
  def [] *x
    self.class.new self+x
  end
  def to_filter_string
    @fs||=self.to_s.encode xml: :text
  end
  def to_s
    self['#APG:ALL'][self.class.prefilter][self.class.filter].map(&:to_s).reject(&:empty?).inject do |x,y| "(#{x}) & (#{y})" end || ''
  end
  def create_message props: [], ts: false, **options
    m = ["<tns:filter>#{to_filter_string}</tns:filter>"]
    m+=props.map do |p|
      raise ArgumentError,"#{p.to_s.inspect}: wrong property format" unless /^[a-z0-9]{1,8}$/.match p
      "<tns:property>#{p}</tns:property>"
    end
    if ts
      start_time,end_time=self.class.current_range **options
      m << "<tns:start-timestamp>#{start_time}</tns:start-timestamp>"
      m << "<tns:end-timestamp>#{end_time}</tns:end-timestamp>"
    end
    m.join "\n"
  end
  #Count number of metrics
  def count
    self.class.client.call(:get_object_count,message:create_message).xpath('//ns2:count').first.text.to_i
  end
  def available_properties description: false
    p=description ? (proc do |p| [p[:name].to_sym,p.text] end) : (proc do |p| p[:name] end)
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
  def get_object_data **options
    xml=self.class.client.call(:get_object_data,message:create_message(ts:true, **options)).to_xml
    Watch4Net::SAX::GetObjectData.parse xml,Hash
  end
  def get_distinct *props
    xml=self.class.client.call(:get_distinct_property_records,message:create_message(props:props)).to_xml
    Watch4Net::SAX::GetDistinctPropertyRecords.parse xml,Array,props
  end
  #Get metrics and its properties and/or values
  # options :
  # * any property name as a symbol
  # * value ; last raw value
  # * timestamp & human_timestamp for the unix time of values, or a formatted one
  # * all_values: true ; will display all the values in the time range
  # * offset: n ; will look for values until n seconds in the past
  # * from: t ; look for values from that moment onwards
  # * until: t ; look for values until that time (default: now)
  # (from and offset are incompatible, from & until accept Date, Time or unix timestamp)
  # ex: "!parttype & source='abcd'".get(:device,:devtype,:name,:value,all_values: true, from: Date.new(2001,1,28))
  def get *props, **options
    all_values=options.delete :all_values
    depr={
      last_rv: :value,
      last_ts: :timestamp,
      last_human_ts: :human_timestamp,
    }
    opts=[:id,:value,:timestamp,:human_timestamp].concat(depr.keys).each_with_object({}) do |k,o| o[k]=props.delete(k) end
    depr.select do |k,_| opts[k] end.each do |k,v|
      STDERR.puts "OPTION %s IS DEPRECATED, PLEASE USE %s INSTEAD" % [k,v].map(&:inspect)
      opts[v]=opts.delete k
    end
    xml=self.class.client.call(:get_object_properties,message:create_message(props:props)).to_xml
    mets=Watch4Net::SAX::GetObjectProperties.parse xml,Array,props
    if opts[:value] or opts[:timestamp] or opts[:human_timestamp]
      vals=get_object_data(options)
      mets.map! do |m|
        v=(x=vals[m.id] ; x[0].zip x[1])
        v.empty? ? m : (all_values ? v : v.slice(-1,1)).map do |z|
          nm=m.clone
          if opts[:value]
            nm.value=z[1]
          end
          if opts[:timestamp]
            nm.timestamp=z[0]
          end
          if opts[:human_timestamp]
            nm.human_timestamp=(z[0].nil? ? nil : Time.at(z[0]).strftime("%a, %b %e %Y %H:%M:%S %z"))
          end
          nm
        end
      end.flatten!
    end
    mets.each do |m| m.delete_field :id end unless opts[:id]
    mets
  end
  def value_per *expansion
    self.get(*expansion,:value).map do |m|
      [m.values_at(*expansion),m.value]
    end.to_h
  end
  def count_per *expansion
    self.get(*expansion).each_with_object(Hash.new 0) do |m,o|
      o[m.values_at(*expansion)]+=1
    end
  end
end
