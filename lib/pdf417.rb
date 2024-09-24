# frozen_string_literal: true

require 'pdf417/pdf417'
require 'pdf417/lib'

# A wrapper for the pdf417lib C Library,
class PDF417
  class GenerationError < StandardError; end

  class << self
    def encode_text(text)
      PDF417::Lib.encode_text(text)
    end
  end

  attr_reader :bit_columns, :bit_rows, :bit_length

  def initialize(*attrs)
    # TODO:  Test these defaults, make sure that they can get set on init, and the output changes accordingly
    self.text = ''
    @y_height = 3
    @aspect_ratio = 0.5
    @rows = nil
    @cols = nil

    if attrs.first.is_a?(String)
      self.text = attrs.first
    elsif attrs.first.is_a?(Hash)
      attrs.first.each do |k, v|
        send(:"#{k}=", v) if respond_to?(:"#{k}=")
      end
    end

    @blob = nil
  end

  def inspect
    "#<#{self.class.name}:#{object_id} >"
  end

  def text=(val)
    @codewords = @blob = nil
    @text = val
  end

  def text
    if @raw_codewords.nil?
      @text
    else
      ''
    end
  end

  def codewords
    return @raw_codewords unless @raw_codewords.nil?

    @codewords ||= self.class.encode_text(text)
  end

  # Y Height
  attr_reader :y_height

  def y_height=(val)
    @blob = nil
    @y_height = val
  end

  # Aspect ratio
  attr_reader :aspect_ratio

  def aspect_ratio=(val)
    @blob = nil
    @rows = nil
    @cols = nil
    @aspect_ratio = val
  end

  # For setting the codewords directly
  attr_reader :raw_codewords

  def raw_codewords=(val)
    @blob = nil
    @raw_codewords = val
  end

  # Make the barcode at least this number of rows
  attr_reader :rows

  def rows=(val)
    @blob = nil
    @rows = val
  end

  # Make the barcode at least this number of columns
  attr_reader :cols

  def cols=(val)
    @blob = nil
    @cols = val
  end

  # Request the specified error level must be between 0 and 8
  attr_reader :error_level

  def error_level=(val)
    @blob = nil
    @error_level = val
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

    if rows.to_i.positive? && cols.to_i.positive?
      lib.code_rows = rows.to_i
      lib.code_cols = cols.to_i
      lib.generation_options |= Lib::PDF417_FIXED_RECTANGLE
      options << "#{rows}x#{cols}"
    elsif rows.to_i.positive?
      lib.code_rows = rows.to_i
      lib.generation_options |= Lib::PDF417_FIXED_ROWS
      options << "#{rows} rows"
    elsif cols.to_i.positive?
      lib.code_cols = cols.to_i
      lib.generation_options |= Lib::PDF417_FIXED_COLUMNS
      options << "#{cols} cols"
    end

    if error_level.to_i >= 0 && error_level.to_i <= 8
      lib.error_level = error_level.to_i
      lib.generation_options |= Lib::PDF417_USE_ERROR_LEVEL
      options << "requested #{error_level.to_i} error level"
    end

    lib.aspect_ratio = aspect_ratio.to_f
    lib.y_height = y_height.to_f

    (@blob = lib.to_blob)
    if @blob.nil? || @blob.empty?
      if lib.generation_error == Lib::PDF417_ERROR_TEXT_TOO_BIG
        raise GenerationError, 'Text is too big'
      elsif lib.generation_error == Lib::PDF417_ERROR_INVALID_PARAMS
        msg = "Invalid parameters: #{options.join(', ')}"
        if (lib.generation_options &
            Lib::PDF417_USE_RAW_CODEWORDS) && lib.raw_codewords.length != lib.raw_codewords.first
          msg += '.  The first element of the raw codwords must be the length of the array.  ' \
                 "Currently it is #{lib.raw_codewords.first}, perhaps it should be #{lib.raw_codewords.length}?"
        end
        raise GenerationError, msg
      else
        raise GenerationError, "Could not generate bitmap error: #{options.join(', ')}"
      end
    else
      @codewords = if lib.raw_codewords.is_a?(Array)
                     lib.raw_codewords
                   else
                     lib.codewords
                   end
      @bit_columns = lib.bit_columns
      @bit_rows = ((lib.bit_columns - 1) / 8) + 1
      @bit_length = lib.bit_length
      @rows = lib.code_rows
      @cols = lib.code_cols
      @error_level = lib.error_level
      @aspect_ratio = lib.aspect_ratio
      @y_height = lib.y_height
      true
    end
  end

  def to_blob
    generate! if @blob.nil?
    @blob
  end
  alias blob to_blob

  def encoding
    generate! if @blob.nil?

    # This matches the output from the pdf417 lib sample output.
    enc = blob.bytes.to_a.each_slice(bit_rows).to_a[0..(rows - 1)] # sometimes we get more rows than expected, truncate

    # The length returned here is too long and we have extra data that gets padded w/ zeroes,
    # meaning it doesn't all match.
    # Eg, instead of ending with "111111101000101001" it ends with "1111111010001010010000000".
    enc.collect do |row_of_bytes|
      row_of_bytes.collect { |x| format('%08b', x) }.join[0..bit_columns - 1]
    end
  end

  def encoding_to_s
    encoding.each { |x| puts x.gsub('0', ' ') }
  end

  def to_chunky_png(opts = {})
    require 'chunky_png' unless defined?(ChunkyPNG)

    generate! if @blob.nil?
    opts[:x_scale] ||= 1
    opts[:y_scale] ||= 3
    opts[:margin] ||= 10
    full_width = (bit_columns * opts[:x_scale]) + (opts[:margin] * 2)
    full_height = (rows * opts[:y_scale]) + (opts[:margin] * 2)

    canvas = ChunkyPNG::Image.new(full_width, full_height, ChunkyPNG::Color::WHITE)

    x = opts[:margin]
    y = opts[:margin]
    booleans = encoding.map { |l| l.chars.map { |c| c == '1' } }
    booleans.each do |line|
      line.each do |bar|
        if bar
          x.upto(x + (opts[:x_scale] - 1)) do |xx|
            y.upto y + (opts[:y_scale] - 1) do |yy|
              canvas[xx, yy] = ChunkyPNG::Color::BLACK
            end
          end
        end
        x += opts[:x_scale]
      end
      y += opts[:y_scale]
      x = opts[:margin]
    end
    canvas
  end

  def to_png(opts = {})
    to_chunky_png(opts).to_datastream.to_s
  end
end
