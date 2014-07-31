module Cli
  class << self
    BANNER = <<-END

    EMC M&R

    To get inline help, enter 'h'

    END
    HELP=<<-END
    Abcd efgh
    TODO
    For more help about the fra....
    END
    def h
      puts HELP
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