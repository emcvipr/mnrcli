module Cli
  class << self
    BANNER = <<-END

    EMC M&R

    To get inline help, enter 'h'

    END
    # Abcd efgh
    # TODO
    # For more help about the fra....
    def h method=:h
      puts self.method(method.to_sym).comment.uncomment
    end
    # inline help here
    def filter string=nil
      string ? Filter[string] : Filter[]
    end
    def start
      puts BANNER
      Pry.start self,prompt_name: nil
    end
    def write filename,something
      File.write filename,something
    end
    alias :f :filter
    alias :w :write
    #Pry::Commands.block_command "h","M&R help" do |x| puts Cli.method(x.to_sym).comment end
  end
end
