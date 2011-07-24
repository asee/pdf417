require 'pdf417/pdf417'

# A barebones ruby interface to the C library, uses C style constants
# and mixes in attribute accessors for moving data back and forth
class PDF417::Lib
  
  PDF417_USE_ASPECT_RATIO = 0
  PDF417_FIXED_RECTANGLE = 1
  PDF417_FIXED_COLUMNS = 2
  PDF417_FIXED_ROWS = 4
  PDF417_AUTO_ERROR_LEVEL = 0
  PDF417_USE_ERROR_LEVEL = 16
  PDF417_USE_RAW_CODEWORDS = 64
  PDF417_INVERT_BITMAP = 128

  PDF417_ERROR_SUCCESS = 0
  PDF417_ERROR_TEXT_TOO_BIG = 1
  PDF417_ERROR_INVALID_PARAMS = 2
  
  # The int representing the options used to generate the barcode, defined in the library as:
  # [PDF417_USE_ASPECT_RATIO] use aspectRatio to set the y/x dimension. Also uses yHeight
  # [PDF417_FIXED_RECTANGLE] make the barcode dimensions at least codeColumns by codeRows
  # [PDF417_FIXED_COLUMNS] make the barcode dimensions at least codeColumns
  # [PDF417_FIXED_ROWS] make the barcode dimensions at least codeRows
  # [PDF417_AUTO_ERROR_LEVEL] automatic error level depending on text size
  # [PDF417_USE_ERROR_LEVEL] the error level is errorLevel. The used errorLevel may be different
  # [PDF417_USE_RAW_CODEWORDS] use codewords instead of text
  # [PDF417_INVERT_BITMAP] invert the resulting bitmap
  #
  # For example
  #   b.generation_options = PDF417::PDF417_INVERT_BITMAP | PDF417::PDF417_AUTO_ERROR_LEVEL
  
  attr_accessor :generation_options, :text, :raw_codewords
  # The following are read from the last generated barcode, but they need a writer because they get set
  attr_writer :code_rows, :code_cols, :error_level, :y_height, :aspect_ratio
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
