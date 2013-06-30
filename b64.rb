require 'base64'
str=""
open("./R.exe","rb+"){|file| str=file.read}
open("./new","w+"){|file| file.print Base64.encode64(str)}
puts "OK"
gets