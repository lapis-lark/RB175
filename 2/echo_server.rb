require "socket"

def parse_params(query)
  h = query.split('&').map do |pair| pair.split('=') 
    k, v = pair.split('=') 
    [k.to_sym, v.to_i]
  end.to_h
end

server = TCPServer.new("localhost", 4509)
loop do
  client = server.accept

  request_line = client.gets
  next if !request_line || request_line =~ /favicon/

  puts request_line
  
  http_method, path, http_version = request_line.split(' ')
  path, query = path.split("?")
  p_hash = parse_params(query)

  client.puts "HTTP/1.0 200 OK"
  client.puts "Content-Type: text/html"
  client.puts
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts "<h1>rolls:</h1>"
  p_hash[:rolls].times { client.puts "<p>#{rand(1..p_hash[:sides])}</p>"}
  client.puts "</pre>"
  client.puts "</body>"
  client.puts "</html>"
 #  p_hash[:rolls].times { client.puts rand(1..p_hash[:sides])}

  client.close
end