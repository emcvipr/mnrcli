module Cli
  class << self
    BANNER = <<-END

    EMC M&R

    To get inline help, enter 'h'

    END
    # Configure your connection to EMC M&R Web-Service in config.yml 
    # To query data use : f["your filter"]
    # Available requests are :
    #  * get_all
    #  *
    def h method=:h
      Pry.output.puts self.method(method.to_sym).comment.uncomment
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
  end
end
