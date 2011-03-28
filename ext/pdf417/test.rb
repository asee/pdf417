require 'pdf417'
puts "Testing codewords for 'fred'"
PDF417.encode_text("fred").each_with_index{|cw,i| puts "Ruby thinks cw #{i} is #{cw}"}
