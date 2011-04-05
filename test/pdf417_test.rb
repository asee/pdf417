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
  
  should "re-generate if the text has been reassigned" do
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
  
end
