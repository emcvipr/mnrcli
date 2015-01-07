module Pry::Command::W4N
  def self.new_command cmd=Pry::ClassCommand,&block
    klass=Class.new cmd,&block
    klass.class_eval do group 'mnrcli' end
    klass.description||='no description'
    Pry::Commands.add_command klass
  end
  module Helpers
    def pr *x,**opts
      s=x.join "\n"
      if f=opts[:file]
        File.write f,s
        puts "Output written to #{f}"
      else
        _pry_.pager.page s
      end
    end
    def tablify *x
      Pry::Helpers.tablify_to_screen_width(*x)
    end
    Pry::ClassCommand.include self
  end
  new_command Pry::Command::Help do
    match 'helpcli'
    def visible_commands
      commands.select do |_,c| c.group == 'mnrcli' end
    end
  end
  new_command do
    match "server"
    description "connect to a different db"
    command_options argument_required: true
    def process host
      # TODO factor with mnrcli.rb
      options={xml: false, user: 'admin', password: 'changeme', host: host}
      Filter.setup options
    end
  end
  new_command do
    match 'write'
    description "blablabla"
    banner <<-BANNER
    abc
    def
    BANNER
    def process
      #file=args.shift
    end
  end
  new_command do
    match 'write_csv'
    def process
    end
  end
  new_command do
    match 'write_table'
    def process
      args.each do |a| p a end
    end
  end
  new_command do
    match 'vi_mode'
    def process
      Readline.respond_to?(:vi_editing_mode) ? Readline.vi_editing_mode : puts('not supported')
    end
  end
  new_command do
    match 'properties'
    def process
      fil=args.shift or ""
      x=Filter[fil].available_properties.sort
      pr tablify(x)
    end
  end
  new_command do
    match 'global_filter'
    command_options argument_required: true
    def process filter
      Filter.prefilter=filter
    end
  end
  new_command do
    match 'summary'
    description 'few statistics about the metrics in the db'
    def process
      h={
        'Server' => Filter.server,
        'Global filter' => Filter.prefilter||'(no filter set)',
        'Metrics' => "".count,
        'Active metrics' => "!vstatus=='inactive'".count,
        'Distinct Properties' => "".available_properties.count,
        'Sources' => :source.values.count,
      }
      fmt="%-#{3+h.keys.map(&:length).max}s:%#{2+h.values.map(&:to_s).map(&:length).max}s"
      pr *(h.each_pair.map do |k,v| fmt % [k,v] end)
    end
  end
end
