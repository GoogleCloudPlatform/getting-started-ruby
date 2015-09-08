# Respond to HTTP requests with non-500 error code
run lambda {|env| [200, {"Content-Type" => "text/plain"}, ["ok"]] }
