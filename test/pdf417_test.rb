begin
  require "RMagick"
rescue LoadError
end

require 'test_helper'

class Pdf417Test <  Minitest::Test
  
  should "initialize text as an attr" do
    b = PDF417.new(:text => "fred")
    assert_equal "fred", b.text
  end
  
  should "initialize text as a single parameter" do
    b = PDF417.new("fred")
    assert_equal "fred", b.text
  end

  should "defaults rows and cols to nil" do
    b = PDF417.new("fred")
    assert_nil b.rows
    assert_nil b.cols
  end

  should "allows fixed cols" do
    b = PDF417.new(text: "01234"*60, error_level: 6, cols: 5)
    b.to_blob
    assert_equal [5, 47], [b.cols, b.rows]

    # if it's too small, auto determine the best value
    b = PDF417.new(text: "01234"*60, error_level: 6, cols: 1)
    b.to_blob
    assert_equal [3, 90], [b.cols, b.rows]

    # if it's too big, auto determine the best value
    b = PDF417.new(text: "01234"*60, error_level: 6, cols: 100)
    b.to_blob
    assert_equal [30, 8], [b.cols, b.rows]
  end

  should "allows fixed rows" do
    b = PDF417.new(text: "01234"*60, error_level: 6, rows: 10)
    b.to_blob
    assert_equal [24, 10], [b.cols, b.rows]

    # if it's too small, auto determine the best value
    b = PDF417.new(text: "01234"*60, error_level: 6, rows: 6)
    b.to_blob
    assert_equal [30, 8], [b.cols, b.rows]

    # if it's too big, auto determine the best value
    b = PDF417.new(text: "01234"*60, error_level: 6, rows: 100)
    b.to_blob
    assert_equal [3, 90], [b.cols, b.rows]
  end

  should "let default aspect_ratio to define rows and cols" do
    b = PDF417.new(text: "01234"*60, error_level: 6)
    b.to_blob
    assert_equal 7, b.cols
    assert_equal 34, b.rows
  end

  should "let custom aspect_ratio to define rows and cols" do
    b = PDF417.new(text: "01234"*60, aspect_ratio: 0.618,
                   error_level: 6)
    b.to_blob
    assert_equal 6, b.cols
    assert_equal 39, b.rows
  end

  should "know the right codewords for fred" do
    assert_equal [4, 815, 514, 119], PDF417.encode_text("fred")
    assert_equal [4, 815, 514, 119], PDF417.new(:text => "fred").codewords
  end
  
  should "re-generate codewords if the text has been reassigned" do
    b = PDF417.new("fred")
    fred_words = b.codewords
    fred_blob = b.to_blob
    b.text = "Joebob"
    assert fred_words != b.codewords
    assert fred_blob != b.to_blob
  end
  
  should "re-generate if the text has been updated" do
    b = PDF417.new("fred")
    fred_words = b.codewords
    fred_blob = b.to_blob
    b.text += " and joe"
    assert fred_words != b.codewords
    assert fred_blob != b.to_blob    
  end
  
  should "re-generate if the options have changed" do
    b = PDF417.new("fred")
    fred_words = b.codewords
    fred_blob = b.to_blob
    b.rows = b.rows + 4
    assert_equal fred_words, b.codewords # NOTE that the codewords have not changed, just the binary blob
    assert fred_blob != b.to_blob    
  end
  
  should "set the text to nil when using raw codewords" do
    b = PDF417.new("TEST") 
    b.raw_codewords = [4, 815, 514, 119]
    assert_equal "", b.text
  end
  
  should "accept raw codewords" do
    b = PDF417.new
    b.raw_codewords = [4, 815, 514, 119]
    assert_equal [4, 815, 514, 119], b.codewords
    begin
      b.to_blob
    rescue Exception => e
      assert false, "Expected nothing raised, instead got #{e.message}"
    end
    assert_barcode b
  end
  
  context "after generating" do
    setup do
      @barcode = PDF417.new("test")
      @barcode.generate!
      @blob = @barcode.blob
    end
    
    should "have a blob" do
      refute_nil @barcode.blob
      refute_nil @barcode.to_blob
      assert_barcode @barcode
    end
    
    should "know bit columns" do
      refute_nil @barcode.bit_columns
    end
    
    should "know bit rows" do
      refute_nil @barcode.bit_rows
    end
    
    should "know bit length" do
      refute_nil @barcode.bit_length
    end
    
    should "know rows" do
      refute_nil @barcode.rows
    end
    
    should "know cols" do
      refute_nil @barcode.cols
    end
    
    should "know error level" do
      refute_nil @barcode.error_level
    end
    
    should "know aspect ratio" do
      refute_nil @barcode.aspect_ratio
    end
    
    should "know y height" do
      refute_nil @barcode.y_height
    end
    
    should "regenerate after rows changed" do
      @barcode.rows = 10
      refute_equal @blob, @barcode.to_blob
      assert_barcode @barcode
    end
    
    should "regenerate after cols changed" do
      @barcode.cols = 10
      refute_equal @blob, @barcode.to_blob
      assert_barcode @barcode
    end
    
    should "regenerate after error level changed" do
      @barcode.error_level = 7
      refute_equal @blob, @barcode.to_blob
      assert_barcode_start_sequence @barcode
      assert_barcode_end_sequence @barcode
    end
    
    should "regenerate after raw codewords changed" do
      @barcode.raw_codewords = @barcode.codewords + [245, 123]
      @barcode.raw_codewords[0] = @barcode.raw_codewords.length
      refute_equal @blob, @barcode.to_blob
      assert_barcode @barcode
    end
        
    should "regenerate after aspect ratio changed" do
      # Aspect ratio does not apply when both rows and cols are set, so re-set our 
      # reference and make sure there is enough data to have rows and cols
      @barcode.text = "SOME REALLY LONG TEXT HERE! Gonna need some rows...." * 10
      @barcode.rows = nil
      @barcode.cols = 10 # fixed cols input
      @barcode.error_level = 3
      @blob = @barcode.to_blob
      assert_equal [10, 30], [@barcode.cols, @barcode.rows] # cols is fixed at 10

      @barcode.aspect_ratio = 1000
      new_blob = @barcode.to_blob
      assert_equal [4, 90], [@barcode.cols, @barcode.rows] # new cols and rows are defined

      refute_equal @blob, new_blob
      assert_barcode_start_sequence @barcode
      assert_barcode_end_sequence @barcode
    end
  end
  
  should "know max rows after generating out of bounds" do
    b = PDF417.new(:rows => 10000, :text => "test")
    b.generate!
    refute_equal 10000, b.rows
  end
  
  
  # if Object.const_defined? "Magick"
  #   context "using RMagick" do
  #     setup do
  #       @barcode = PDF417.new("test text" * 100)
  #       @barcode.generate!
  #     end
  #     
  #     should "make an image" do
  #       # @barcode.to_blob.split(//).collect{|x| x.unpack("B*")}.to_s.inspect
  #       image = Magick::Image::from_blob(@barcode.to_blob).first
  #       puts "Width: #{image.columns}; Height: #{image.rows}"
  #     end
  #   end      
  # else
  #   puts "*** Skipping rmagick tests"
  # end
  
  
  
end
