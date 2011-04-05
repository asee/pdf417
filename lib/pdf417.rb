require 'pdf417/pdf417'
require 'pdf417/lib'

class PDF417
  
  class GenerationError < StandardError; end
  
  class << self
    def encode_text(text)
      PDF417::Lib.encode_text(text)
    end    
  end
  
  # The text to encode
  attr_accessor :text
  # Y Height
  attr_accessor :y_height
  # Aspect ratio
  attr_accessor :aspect_ratio
  # For setting the codewords directly
  attr_accessor :raw_codewords
  # Make the barcode at least this number of rows
  attr_accessor :rows
  # Make the barcode at least this number of columns
  attr_accessor :cols
  # Request the specified error level must be between 0 and 8
  attr_accessor :error_level
  # Invert the bitmap?
  attr_accessor :invert_bitmap
  # The number of columns in the bitmap
  attr_reader :bit_columns
  
  def initialize(*attrs)
    if attrs.first.is_a?(String)
      self.text = attrs.first
    elsif attrs.first.is_a?(Hash)      
      attrs.first.each do |k,v|
        if self.respond_to?("#{k}=".to_sym)
          self.send("#{k}=".to_sym, v)
        end
      end
    end

    self.text ||= ""
    @y_height = 3
    @aspect_ratio = 0.5
  end
  
  
  def text=(val)
    @codewords = nil
    @text = val
  end
  
  def text
    if @raw_codewords.nil?
      @text
    else
      ""
    end
  end
  
  def codewords
    return @raw_codewords if !@raw_codewords.nil?
    @codewords ||= self.class.encode_text(text)
  end
    
  def invert_bitmap?
    !! self.invert_bitmap
  end
  
  def to_blob
    lib = Lib.new(text)
    options = []
    # Setting the text via accessor will set the codewords to nil, but if they have
    # been manually set pass them on.
    if @raw_codewords.is_a?(Array)
      lib.raw_codewords = @raw_codewords
      lib.generation_options |= Lib::PDF417_USE_RAW_CODEWORDS
      options << 'raw codewords'
    end
    
    if self.invert_bitmap?
      lib.generation_options |= Lib::PDF417_INVERT_BITMAP
      options << 'inverting bitmap'
    end
    
    if self.rows.to_i > 0 && self.cols.to_i > 0
      lib.code_rows = self.rows
      lib.code_cols = self.cols
      lib.generation_options |= Lib::PDF417_FIXED_RECTANGLE
      options << "#{rows}x#{cols}"
    elsif self.rows.to_i > 0
      lib.code_rows = self.rows.to_i 
      lib.generation_options |= Lib::PDF417_FIXED_ROWS
      options << "#{rows} rows"
    elsif self.cols.to_i > 0
      lib.code_cols = self.cols.to_i
      lib.generation_options |= Lib::PDF417_FIXED_COLUMNS
      options << "#{cols} cols"
    end
    
    if self.error_level.to_i >= 0 && self.error_level.to_i <= 8
      lib.error_level = self.error_level.to_i
      lib.generation_options |= Lib::PDF417_USE_ERROR_LEVEL
      options << "requested #{error_level.to_i} error level"
    end
    
    lib.aspect_ratio = self.aspect_ratio.to_f
    lib.y_height = self.y_height.to_f
    
    (blob = lib.to_blob)
    if blob.nil?
      if lib.generation_error == Lib::PDF417_ERROR_TEXT_TOO_BIG
        raise GenerationError, "Text is too big"
      elsif lib.generation_error == Lib::PDF417_ERROR_INVALID_PARAMS
        raise GenerationError, "Invalid parameters: #{options.join(', ')}"
      else
        raise GenerationError, "Could not generate bitmap: #{options.join(', ')}"
      end
    else
      
      @codewords = lib.codewords
      @bit_columns = lib.bit_columns
      @rows = lib.code_rows
      @cols = lib.code_columns
      @error_level = lib.error_level
      @aspect_ratio = lib.aspect_ratio
      @y_height = lib.y_height
      
      blob
    end
    
  end
  

  
end
