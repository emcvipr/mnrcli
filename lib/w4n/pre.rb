# ruby 2.0 doesn't provide [].to_h
unless Array.instance_methods.include? :to_h
  class Array
    def to_h
      each_with_object({}) do |(k,v),o|
        o[k]=v
      end
    end
  end
end

# .include and .prepend are private in ruby 2.0
unless [:include,:prepend].all? {|x| Module.instance_methods.include? x}
  module Kernel
    def publicize *methods
      self.send :prepend,Module.new {methods.each do |m| define_method m do |*a,&b| super *a,&b end end}
    end
  end
  Module.publicize :include,:prepend
end
