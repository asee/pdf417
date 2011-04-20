
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'ext'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'pdf417'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'ruby-debug'


class Test::Unit::TestCase
end

def assert_barcode(barcode, msg = nil)
  full_message = build_message(msg, "? should have a valid PDF417 start and end sequence for each row", barcode)
  assert_block(full_message) do
    barcode.encoding.any? && barcode.encoding.all?{|x| x.start_with?("11111111010101000") && x.end_with?("1111111010001010010") }
  end
end

def assert_inverse_barcode(barcode, msg = nil)
  full_message = build_message(msg, "? should have a valid PDF417 start and end sequence for each row", barcode)
  assert_block(full_message) do
    barcode.encoding.any? && barcode.encoding.all?{|x| x.start_with?("00000000101010111") && x.end_with?("0000000101110101101") }
  end
end