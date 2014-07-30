require 'w4n/ostruct'

class Metric < Watch4Net::OpenStruct
  def explode property,separator='|'
    self[property].split(separator).map do |np|
      n=self.clone
      n[property]=np
      n
    end
  end
end

class Array
  def explode property,separator='|'
    self.map do |e| e.explode property,separator end.flatten
  end
  def expand_on *properties
    self.group_by do |m|
      properties.map do |p|
        m[p]
      end
    end.reject do |k|
      k.include? nil
    end.values
  end
  def value_sum_on *properties
    self.expand_on(*properties).map do |z|
      r=z.map(&:value).reject(&:nil?).inject(0,:+)
      p=properties.map do |x| z.first[x] end
      [p,r]
    end.to_h
  end
end
