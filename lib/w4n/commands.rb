module Pry::Command::W4N
  def self.new_command cmd=Pry::ClassCommand,&block
    klass=Class.new cmd,&block
    klass.class_eval do group 'mnrcli' end
    klass.description||='no description'
    Pry::Commands.add_command klass
  end
  module Helpers
    def pr *x, file: nil
      s=x.join "\n"
      if file
        File.write file,s
        _pry_.output.puts "Output written to #{file}"
      else
        _pry_.pager.page s
      end
    end
    def tablify *x
      Pry::Helpers.tablify_to_screen_width(*x)
    end
    def prop_parse *o
      o.join(' ').gsub(/:/,'').split(/,|\s+/).partition do |x| not x.gsub!(/^!/,'') end.map do |x| x.map(&:to_sym) end
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
    def process host,user='admin',pass='changeme'
      Filter.setup user: user, password: pass, host: host
    end
  end
  new_command do
    match 'write'
    description "blablabla"
    command_options shellwords: false
    banner <<-BANNER
    abc
    def
    BANNER
    def options opt
      opt.on :f, :file, "write output to a file", :argument => true
    end
    def process
      r=target.eval args.join(' ')
      pr r,file: opts[:f]
    end
  end
  new_command do
    match 'write_csv'
    command_options alias: 'csv'
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
    match 'properties_description'
    def process
      fil=args.shift or ""
      x=Filter[fil].available_properties(description: true).to_h.sort.map do |(p,d)|
        c=d.empty? ? :yellow : :green
        text.send(c,"%-8s  " % p)+d
      end
      pr x
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
    match 'metrics'
    command_options argument_required: true
    def process filter,*p
      o=[]
      f=Filter[filter]
      wnt,dnw=prop_parse(p)
      props=wnt.empty? ? f.available_properties.map(&:to_sym) : wnt
      props-=dnw
      props << :id
      mets=filter.get(*props)
      mets.each do |m|
        o << text.bright_blue(m.id)
        x=[]
        m.each_pair.sort.each do |(p,v)|
          next if :id == p
          x << text.green("%-8s" % p)+" #{v}"
        end
        o << tablify(x)
        o << ''
      end
      o << text.yellow("#{mets.count} metrics for: #{filter}\n")
      pr o
    end
  end
  new_command do
    match 'inspect'
    command_options argument_required: true
    def process filter,*p
      o=[]
      f=Filter[filter]
      wnt,dnw=prop_parse(p)
      props=wnt.empty? ? f.available_properties.map(&:to_sym) : wnt
      props-=dnw
      mets=filter.get(*props)
      h=props.each_with_object({}) do |p,o|
        o[p]=mets.map(&p.to_sym).each_with_object(Hash.new(0)) do |v,q|
          q[v]+=1
        end
      end
      count=mets.count
      h.sort.each do |(p,y)|
        o << text.bright_blue(p)
        x=[]
        y.sort_by do |(v,_)| v||'' end.each do |(v,c)|
          x << (v ? v : text.red('∅'))
          x << text.send((c==count ? :cyan : :green),c.to_s)
        end
        x.each_slice(2) do |p,c| o << "  %16s  %s" % [c,p] end
      end
      o << ''
      o << text.yellow("#{count} metrics for: #{filter}\n")
      pr o
    end
  end
  new_command do
    match 'summary'
    description 'few statistics about the metrics in the db'
    def process
      h={
        'Server'              => Filter.server,
        'Global filter'       => ((f=Filter.prefilter).to_s.empty? ? '(no filter set)' : f),
        'Metrics'             => "".count,
        'Active metrics'      => "!vstatus=='inactive'".count,
        'Distinct Properties' => "".available_properties.count,
        'Databases'           => :apgdb.values.count,
        'Sources'             => :source.values.count,
      }
      fmt="%-#{3+h.keys.map(&:length).max}s:%#{2+h.values.map(&:to_s).map(&:length).max}s"
      pr *(h.each_pair.map do |k,v| fmt % [k,v] end)
    end
  end
  new_command do
    match 'prop_per_source'
    def process
      seen=Hash.new(0)
      x=:source.values.each_with_object(Hash.new) do |s,o|
        o[s]="source=='#{s}'".available_properties
        o[s].each do |p| seen[p]+=1 end
      end
      o=x.sort.each_with_object([]) do |(s,v),o|
        o << text.bright_blue(s)
        y=v.sort.map do |p| text.send((seen[p]==1 ? :red : :green),p) end
        o << tablify(y)
      end
      pr o#,file: './outout'
    end
  end
  new_command do
    match 'trace_toggle'
    def process
      g=Filter.client.globals
      [:pretty_print_xml,:log].each do |p| g[p]=!g[p] end
    end
  end
  new_command do
    match 'load_file'
    command_options argument_required: true
    def process file
      _pry_.output.puts "\n"
      _pry_.input=File.open file
    end
  end
  new_command do
    match 'output'
    def options opt
      opt.on :c, :color, "keep color in the output"
      opt.on :s, :stdout, "display the output back on stdout"
    end
    def process file
      p=_pry_
      if opts[:s]
        p.output=STDOUT
        p.color=true
      else
        unless opts[:c]
          p.color=false
        end
        raise Pry::CommandError,"must specify a file" unless file
        p.output=File.open file,'w'
        p.pager=nil
      end
    end
  end
end
