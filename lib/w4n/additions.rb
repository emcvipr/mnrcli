class String
  def uncomment
    gsub /(^|\n)#\s*/,'\1'
  end
end

class Date
  def self.yesterday
    self.today.prev_day
  end
end

class Array
  def format_table header: nil, align_right: []
    array=self.clone
    array.unshift header if header
    max_per_row=(0..array.first.size-1).map do |i| array.map do |x| x[i].to_s.size end.max end
    line_sep=max_per_row.map do |x| '-'*x end.join('-+-')+'-'
    format=(max_per_row[0..-2].map.with_index do |x,i|
      "%%%s%ss" % [align_right[i]?'':'-',x]
    end.push "%s").join ' | '
    res=array.map do |x| format % x end
    (header ? [0,2,-1] : [0,-1]).each do |x| res.insert x,line_sep end
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
      return ["No metrics"]
    end
    ms=map.map(&:to_h)
    keys=ms.map(&:keys).flatten.uniq if keys.empty?
    res=ms.map do |m|
      m.values_at(*keys)
    end
    r=res.format_table header: keys
    r<<"\n%d metric%s\n" % [size, size==1 ? '' : 's']
    r
  end
end

class Hash
  def sym_keys
    each_with_object({}) do |(k,v),o|
      o[k.to_sym]=v
    end
  end
  def slice *keys
    keys.each_with_object({}) do |k,o| o[k]=self[k] if self.key? k end
  end
end
