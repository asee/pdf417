require 'pdf417/pdf417'

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
