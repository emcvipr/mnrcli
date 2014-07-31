class String
  def uncomment
    gsub /(^|\n)#\s*/,'\1'
  end
end

class Array
  def format_table **options
    opts={header: nil, align_right: []}.merge options
    array=self.clone
    array.unshift opts[:header] if opts[:header]
    max_per_row=(0..array.first.size-1).map do |i| array.map do |x| (x[i]||'').size end.max end
    line_sep=max_per_row.map do |x| '-'*x end.join('-+-')+'-'
    format=(max_per_row[0..-2].map.with_index do |x,i|
      "%%%s%ss" % [opts[:align_right][i]?'':'-',x]
    end.push "%s").join ' | '
    res=array.map do |x| format % x end
    (opts[:header] ? [0,2,-1] : [0,-1]).each do |x| res.insert x,line_sep end
    res.join "\n"
  end
  def to_csv delimiter=';'
    ms=map.map(&:to_h)
    ks=ms.map(&:keys).flatten.uniq
    h="#"+ks.join(delimiter)+"\n"
    csv=(ms.map do |m|
      m.values_at(*ks).join delimiter
    end.join("\n"))
    h+csv
  end
  def table *keys
    if empty?
      return puts "No metrics"
    end
    ms=map.map(&:to_h)
    keys=ms.map(&:keys).flatten.uniq if keys.empty?
    res=ms.map do |m|
      m.values_at(*keys)
    end
    puts res.format_table header: keys
    puts "%d metric%s" % [size, size==1 ? '' : 's']
  end
end

class Hash
  def sym_keys
    each_with_object({}) do |(k,v),o|
      o[k.to_sym]=v
    end
  end
end
