# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] || 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  user_name = params['user_name']
  user_password = params['user_password']
  if user_name == 'admin' && user_password == 'secret'
    session[:identity] = user_name
  end
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

post '/visit' do
  @user_name = params[:user_name]
  @user_phone = params[:user_phone]
  @date_time = params[:date_time]
  @master = params[:master]
  @color = params[:color]
  hh = { user_name: 'Введите имя',
         user_phone: 'Введите телефон',
         date_time: 'Введите дату и время' }
  hh.each do |key, _value|
    if params[key] == ''
      @error = hh[key]
      return erb :visit
    end
  end
  f = File.open './public/users.txt', 'a'
  f.write "User: #{@user_name}, Phone: #{@user_phone}, Date and time: #{@date_time}, Master: #{@master} \r\n"
  f.close
  erb "#{@user_name}==#{@user_phone}==#{@date_time}==#{@master}==#{@color}"
end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @user_email = params[:user_email]
  @user_info = params[:user_info]
  f = File.open './public/contacts.txt', 'a'
  f.write "Email: #{@user_email} \r\n"
  f.write "Info: #{@user_info} \r\n"
  f.write "\r\n\r\n"
  f.close
  erb "#{@user_email}<br/>#{@user_info}"
end
