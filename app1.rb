# frozen_string_literal: true

require 'sinatra'

get '/' do
  erb :index
end

post '/' do
  @login = params[:login]
  erb :index
end
