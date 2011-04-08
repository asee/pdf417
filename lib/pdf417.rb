require 'pdf417/pdf417'
require 'pdf417/lib'

class PDF417
  
  class GenerationError < StandardError; end
  
  class << self
    def encode_text(text)
      PDF417::Lib.encode_text(text)
    end    
  end

  attr_reader :bit_columns, :bit_rows, :bit_length
  
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
    @rows = 1
    @cols = 0
    @blob = nil
  end
  
  
  def text=(val)
    @codewords = @blob = nil
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
      
  # Y Height
  def y_height
    @text
  end
  def y_height=(val)
    @blob = nil
    @y_height = val
  end
    
  # Aspect ratio
  def aspect_ratio
    @aspect_ratio
  end
  def aspect_ratio=(val)
    @blob = nil
    @aspect_ratio = val
  end
    
  # For setting the codewords directly
  def raw_codewords
    @raw_codewords
  end
  def raw_codewords=(val)
    @blob = nil
    @raw_codewords = val
  end
    
  # Make the barcode at least this number of rows
  def rows
    @rows
  end
  def rows=(val)
    @blob = nil
    @rows = val
  end
    
  # Make the barcode at least this number of columns
  def cols
    @cols
  end
  def cols=(val)
    @blob = nil
    @cols = val
  end
    
  # Request the specified error level must be between 0 and 8
  def error_level
    @error_level
  end
  def error_level=(val)
    @blob = nil
    @error_level = val
  end
    
  # Invert the bitmap?
  def invert_bitmap
    @invert_bitmap
  end
  
  def invert_bitmap=(val)
    @blob = nil
    @invert_bitmap = val
  end
  
  def generate!
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
      lib.code_rows = self.rows.to_i
      lib.code_cols = self.cols.to_i
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
  
    (@blob = lib.to_blob)
    if @blob.nil?
      if lib.generation_error == Lib::PDF417_ERROR_TEXT_TOO_BIG
        raise GenerationError, "Text is too big"
      elsif lib.generation_error == Lib::PDF417_ERROR_INVALID_PARAMS
        msg = "Invalid parameters: #{options.join(', ')}"
        if lib.generation_options & Lib::PDF417_USE_RAW_CODEWORDS && lib.raw_codewords.length != lib.raw_codewords.first
          msg +=".  The first element of the raw codwords must be the length of the array.  Currently it is #{lib.raw_codewords.first}, perhaps it should be #{lib.raw_codewords.length}?"
        end
        raise GenerationError, msg
      else
        raise GenerationError, "Could not generate bitmap: #{options.join(', ')}"
      end
    else
      @codewords = lib.codewords
      @bit_columns = lib.bit_columns
      # @bit_rows = (lib.bit_columns / 8) + 1
      @bit_length = lib.bit_length
      @rows = lib.code_rows 
      @cols = lib.code_columns
      @error_level = lib.error_level
      @aspect_ratio = lib.aspect_ratio
      @y_height = lib.y_height
      return true
    end
  end
    
  
  def to_blob
    self.generate! if @blob.nil?
    @blob    
  end      
  alias_method :blob, :to_blob
  
  def encoding
    self.generate! if @blob.nil?

    cols = self.bit_columns / 8 + 1
    # The below sets it up so that @blob.unpack("B*").first == enc.join
    # The barby library has
    #         row << sprintf("%08b", (byte & 0xff) | 0x100)
    # Not sure what that's about, Binary OR Operator copies a bit if it exists in eather operand 0x100 = 265, eg, ensuring everything is >= 256
    # Enc yields an array of strings, such as:
    # ["11111111010101000111010101110000001111010100111100010000010111011100111101010111100001111111010001010010", "11111111010101000111101010010000001110001001101000010100111111011100111110101011000001111111010001010010", "11111111010101000111010101111110001010010001111000010111100111011100101010011110000001111111010001010010", "011010110100111001001111010101000100111101010000"]
    # enc = []
    # row = nil
    # n = 0
    # @blob.each_byte do |byte|
    #   if n%cols == 0
    #     row = ""
    #     enc << row
    #   end
    #   row << sprintf("%08b", (byte & 0xff))
    #   n += 1
    # end
    # enc
    
    # NOTE:  Couldn't cols also be self.rows??
    
    # This matches the output from the pdf417 lib sample output, for each byte try sprintf("%02X", byte) to get the hex, or sprintf("%08b", byte) to get the binary
    enc = b.blob.bytes.to_a.each_slice(cols).to_a
    
    return enc.collect do |row_of_bytes|
      row_of_bytes.collect{|x| sprintf("%08b", x)}.join
    end
  end

  

  
end
