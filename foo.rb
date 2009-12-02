require 'rubygems'
require 'bertrpc'

puts "Sending"
svc = BERTRPC::Service.new('localhost', 11300)
puts svc.call.hello_world.calc(10,20,30).inspect
