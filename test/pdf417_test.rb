require 'test_helper'

class Pdf417Test < Test::Unit::TestCase
  
  should "initialize text as an attr" do
    b = PDF417.new(:text => "fred")
    assert_equal "fred", b.text
  end
  
  should "initialize text as a single parameter" do
    b = PDF417.new("fred")
    assert_equal "fred", b.text
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
    b.invert_bitmap = ! b.invert_bitmap
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
    assert_nothing_raised do
      b.to_blob
    end
  end
  
  context "after generating" do
    setup do
      @barcode = PDF417.new("test")
      @barcode.generate!
      @blob = @barcode.blob
    end
    
    should "have a blob" do
      assert_not_nil @barcode.blob
      assert_not_nil @barcode.to_blob
    end
    
    should "know bit columns" do
      assert_not_nil @barcode.bit_columns
    end
    
    should "know rows" do
      assert_not_nil @barcode.rows
    end
    
    should "know cols" do
      assert_not_nil @barcode.cols
    end
    
    should "know error level" do
      assert_not_nil @barcode.error_level
    end
    
    should "know aspect ratio" do
      assert_not_nil @barcode.aspect_ratio
    end
    
    should "know y height" do
      assert_not_nil @barcode.y_height
    end
    
    should "regenerate after rows changed" do
      @barcode.rows = 10
      assert_not_equal @blob, @barcode.to_blob
    end
    
    should "regenerate after cols changed" do
      @barcode.cols = 10
      assert_not_equal @blob, @barcode.to_blob
    end
    
    should "regenerate after error level changed" do
      @barcode.error_level = 7
      assert_not_equal @blob, @barcode.to_blob
    end
    
    should "regenerate after raw codewords changed" do
      @barcode.raw_codewords = @barcode.codewords + [245, 123]
      @barcode.raw_codewords[0] = @barcode.raw_codewords.length
      assert_not_equal @blob, @barcode.to_blob
    end
    
    should "regenerate invert bitmap changed" do
      @barcode.invert_bitmap = !@barcode.invert_bitmap
      assert_not_equal @blob, @barcode.to_blob
    end
    
    should "regenerate after aspect ratio changed" do
      # Aspect ratio does not apply when both rows and cols are set, so re-set our 
      # reference and make sure there is enough data to have rows and cols
      @barcode.text = "SOME REALLY LONG TEXT HERE! Gonna need some rows...." * 10
      @barcode.rows = nil
      @barcode.cols = 2
      @barcode.error_level = 3
      @blob = @barcode.to_blob
      @barcode.aspect_ratio = 1000
      assert_not_equal @blob, @barcode.to_blob
    end

    should "regenerate after y height changed" do
      # Y Height does not apply when both rows and cols are set, so re-set our 
      # reference and make sure there is enough data to have rows and cols
      @barcode.text = "SOME REALLY LONG TEXT HERE! Gonna need some rows...." * 10
      @barcode.rows = nil
      @barcode.cols = 2
      @barcode.error_level = 3
      @blob = @barcode.to_blob
      @barcode.y_height = 4
      assert_not_equal @blob, @barcode.to_blob
    end
  end
  
  should "know max rows after generating out of bounds" do
    b = PDF417.new(:rows => 1000000, :text => "test")
    b.generate!
    assert_not_equal 1000000, b.rows
  end
  
  
  
end
