require 'test_helper'

class PDF417::Lib::LibTest < Test::Unit::TestCase
  
  should "initialize text" do
    b = PDF417::Lib.new("fred")
    assert_equal "fred", b.text
  end
  
  should "initialize generation_options" do
    b = PDF417::Lib.new("fred")
    assert_equal 0, b.generation_options
  end
  
  should "know the right codewords for fred" do
    assert_equal [4, 815, 514, 119], PDF417::Lib.encode_text("fred")
    assert_equal [4, 815, 514, 119], PDF417::Lib.new("fred").codewords
  end
  
  should "re-generate if the text has been reassigned" do
    b = PDF417::Lib.new("fred")
    fred_words = b.codewords
    fred_blob = b.to_blob
    b.text = "Joebob"
    assert fred_words != b.codewords
    assert fred_blob != b.to_blob
  end
  
  should "re-generate if the text has been updated" do
    b = PDF417::Lib.new("fred")
    fred_words = b.codewords
    fred_blob = b.to_blob
    b.text += " and joe"
    assert fred_words != b.codewords
    assert fred_blob != b.to_blob    
  end
  
  should "re-generate if the options have changed" do
    b = PDF417::Lib.new("fred")
    fred_words = b.codewords
    fred_blob = b.to_blob
    b.generation_options = PDF417::Lib::PDF417_INVERT_BITMAP
    assert_equal b.generation_options, PDF417::Lib::PDF417_INVERT_BITMAP
    assert_equal fred_words, b.codewords # NOTE that the codewords have not changed, just the binary blob
    assert fred_blob != b.to_blob    
  end
  
  should "work when generation options are set weird" do
    b = PDF417::Lib.new("fred")
    b.generation_options = "ALBERT"
    assert b.codewords.is_a?(Array)
  end
  
  
end
