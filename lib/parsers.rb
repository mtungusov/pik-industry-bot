require 'oga'


in_file = File.open 'files/test.htm'
doc = Oga.parse_html in_file
img2 = doc.at_css 'svg'
File.open('files/test.svg', 'w') { |file| file.write img2.to_ }