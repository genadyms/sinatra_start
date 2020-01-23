# frozen_string_literal: true

require 'sinatra'

get '/' do
  erb :index
end

get '/contacts' do
  @title = 'Contacts'
  @message = 'Contacts message'
  erb :message
end

post '/' do
  @login = params[:login]
  @password = params[:password]
  if @login == 'admin' && @password == 'secret'
    erb :welcome
  else
    @message = 'Access denied!'
    erb :index
  end
end
