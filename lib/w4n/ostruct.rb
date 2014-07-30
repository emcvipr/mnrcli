require 'ostruct'
module Watch4Net
  class OpenStruct < ::OpenStruct
    # pristine openstruct is slooooooow since it doesn't define
    # methods class-wide
    def method_missing m,*args,&block
      if (x=m.to_s).chomp!('=')
        raise ArgumentError if args.size != 1 or block
        return self[x]=args[0]
      end
      self.class.class_eval "def #{m} ; @table.fetch(:#{m},nil) ; end"
      @table[m]
    end
    def initialize h
      @table=h.to_h.each_with_object({}) do |(k,v),o|
        o.store k.to_sym,v
      end
    end
    def values_at *x
      @table.values_at *x
    end
  end
  unless Array.instance_methods.include? :to_h
    class ::Array
      def to_h
        each_with_object({}) do |(k,v),o|
          o[k]=v
        end
      end
    end
  end
end
