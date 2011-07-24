
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
    barcode.encoding.any? && barcode.encoding.all?{|x| x.start_with?("11111111010101000") && x.end_with?("111111101000101001") }
  end
end

def assert_barcode_start_sequence(barcode, msg = nil)
  full_message = build_message(msg, "? should have a valid PDF417 start sequence for each row", barcode)
  assert_block(full_message) do
    barcode.encoding.any? && barcode.encoding.all?{|x| x.start_with?("11111111010101000")}
  end
end


def assert_barcode_end_sequence(barcode, msg = nil)
  full_message = build_message(msg, "? should have a valid PDF417 end sequence for each row", barcode)
  assert_block(full_message) do
    barcode.encoding.any? && barcode.encoding.all?{|x| x.end_with?("111111101000101001") }
  end
end
