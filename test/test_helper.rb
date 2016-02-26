
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'ext'))
# $LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../ext', __FILE__)
require 'pdf417'
require 'minitest/autorun'
require 'shoulda'


def assert_barcode(barcode, msg = nil)
  full_message = message(msg) { "Expected #{mu_pp(barcode)} to have a valid PDF417 start and end sequence for each row" }
  assert (barcode.encoding.any? && barcode.encoding.all?{|x| x.start_with?("11111111010101000") && x.end_with?("111111101000101001") }), full_message
end

def assert_barcode_start_sequence(barcode, msg = nil)
  full_message = message(msg) { "Expected #{mu_pp(barcode)} to have a valid PDF417 start sequence for each row" }
  assert (barcode.encoding.any? && barcode.encoding.all?{|x| x.start_with?("11111111010101000")}), full_message
end


def assert_barcode_end_sequence(barcode, msg = nil)
  full_message = message(msg) { "Expected #{mu_pp(barcode)} to have a valid PDF417 end sequence for each row" }
  assert (barcode.encoding.any? && barcode.encoding.all?{|x| x.end_with?("111111101000101001") }), full_message
end
