# frozen_string_literal: true

require 'sinatra'

get '/' do
  erb :index
end

post '/' do
  @name = params[:name]
  @phone = params[:phone]
  @date_time = params[:date_time]

  @title = 'Thank you'
  @message = "Dear #{@name}, we'll be waiting for you at #{@date_time}"

  f = File.open 'users.txt', 'a'
  f.write "User: #{@name}, Phone: #{@phone}, Date and time: #{@date_time} \r\n"
  f.close

  erb :message
end

get '/admin' do
  @file_info = File.open('users.txt', 'r')
  erb :admin
end
