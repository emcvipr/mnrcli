require 'nokogiri'
require 'w4n/metric'

module Watch4Net
  module SAX
    module Parser
      def parse xml,klass,*other
        Nokogiri::XML::SAX::Parser.new(self.new res=klass.new,*other).parse(xml)
        res
      end
    end
    class GetObjectData < Nokogiri::XML::SAX::Document
      extend Parser
      def initialize o
        @ret,@id=o,nil
      end
      def start_element name,attrs=[]
        if 'ns2:timeserie'.eql? name
          attrs.each do |(a,v)|
            if 'id'.eql? a
              @id=v
              @ret[@id]=[]
            end
          end
        elsif 'ns2:tv'.eql? name
          attrs.each do |(a,v)|
            if 'v'.eql? a
              @ret[@id] << v.to_f
            end
          end
        end
      end
    end
    class GetDistinctPropertyRecords < Nokogiri::XML::SAX::Document
      extend Parser
      def initialize o,props
        @props,@in_value,@vals,@l=props,false,[],o
      end
      def start_element name,attrs=[]
        @in_value='ns2:value'.eql? name
      end
      def end_element name
        if 'ns2:record'.eql? name
          @l << Metric.new(@props.zip @vals)
          @vals=[]
        end
      end
      def characters str
        @vals << str if @in_value
      end
    end
    class GetObjectProperties < Nokogiri::XML::SAX::Document
      extend Parser
      def initialize o,props
        @props,@l,@h,@pname=props,o,{},nil
      end
      def start_element name,attrs=[]
        if 'ns2:value'.eql? name
          @pname=attrs[0][1] # very fishy but fast
        elsif 'ns2:properties'.eql? name
          @h[:id]=attrs[0][1] # fishy too
        end
      end
      def end_element name
        if 'ns2:properties'.eql? name
          @l << Metric.new(@h)
          @h={}
        end
      end
      def characters str
        @h[@pname]=str
      end
    end
  end
end
