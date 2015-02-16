require 'w4n/pry'

module Cli
  class << self
    # Configure your connection to EMC M&R Web-Service in config.yml
    # To query data use : "your filter"
    # You can get filter completion with <tab>
    # Methods arguments are symbols. To get completion use : then <tab>
    def h method=:h
      Pry.output.puts self.method(method.to_sym).comment.uncomment
    end
    # inline help here
    def filter string=nil
      string ? Filter[string] : Filter[]
    end
    def start
      Pry.output.puts <<-END.gsub /^ {6}/,''

        EMC M&R on #{Filter.server}

      To list all commands, type 'help'
      For help about a specific command, type 'help mycommand'
      The list of M&R specific commands is available via 'helpcli'

      END
      conf={
        should_load_plugins: false,
        completer: Pry::W4NCompleter,
        prompt_name: nil,
        #input: File.open('myfile.txt'),
      }
      Pry.start self,**conf
    end
    alias :f :filter
  end
end
