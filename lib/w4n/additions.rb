class String
  def uncomment
    gsub /(^|\n)#\s*/,'\1'
  end
end

class Array
  def to_csv delimiter=';'
    ms=map.map(&:to_h)
    ks=ms.map(&:keys).flatten.uniq
    h="#"+ks.join(delimiter)+"\n"
    csv=(ms.map do |m|
      m.values_at(*ks).join delimiter
    end.join("\n"))
    h+csv
  end
end

class Hash
  def sym_keys
    each_with_object({}) do |(k,v),o|
      o[k.to_sym]=v
    end
  end
end
