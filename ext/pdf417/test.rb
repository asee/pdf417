require 'pdf417'

class PDF417
  attr_accessor :text
  def inspect # :nodoc:
    attributes = inspect_attributes.reject { |x|
      begin
        attribute = send x
        !attribute || (attribute.respond_to?(:empty?) && attribute.empty?)
      rescue NoMethodError
        true
      end
    }.map { |attribute|
      "#{attribute.to_s}=#{send(attribute).inspect}"
    }.join ' '
    "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{attributes}>"
  end
  
  
  private
  def inspect_attributes
    [:text, :bit_columns, :bit_length, :code_rows, :code_columns, :codeword_length, :error_level, :generation_options, :aspect_ratio, :y_height, :generation_error]
  end
end


puts "Testing codewords for 'fred'"
PDF417.encode_text("fred").each_with_index{|cw,i| puts "Ruby thinks cw #{i} is #{cw}"}
# For fred, should return:
# Ruby thinks cw 0 is 4
# Ruby thinks cw 1 is 815
# Ruby thinks cw 2 is 514
# Ruby thinks cw 3 is 119

p = PDF417.new("test")
puts p.inspect
p = PDF417.new("fred")
puts p.text
puts p.codewords.inspect
puts p.to_blob.inspect
puts p.bit_columns
puts p.bit_length
puts p.code_rows
puts p.code_columns
puts p.codeword_length
puts p.error_level
puts p.generation_options
puts p.aspect_ratio
puts p.y_height
puts p.generation_error
puts p.inspect