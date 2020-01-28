# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'carretailshop.db'
  db.results_as_hash = true
  return db
end

configure do
  enable :sessions
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT,
    "phone" TEXT,
    "datestamp" TEXT,
    "master" TEXT,
    "color" TEXT
  );'
  db.execute 'CREATE TABLE IF NOT EXISTS "masters"
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT
  );'
  count_masters = db.execute 'SELECT * FROM masters;'
  if count_masters.empty?
    masters = ['Вася суппорта', 'Алексей электрик', 'Саша директор', 'Дима подвеска']
    masters.each { |name| db.execute 'INSERT INTO masters (name) VALUES (?)', [name] }
  end
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
  db = get_db
  @masters = db.execute 'SELECT * FROM masters'
  puts @masters
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
  @error = hh.select { |key, _value| params[key] == '' }.values.join(', ')
  return erb :visit if @error != ''

  db = get_db
  db.execute 'INSERT INTO users (name, phone, datestamp, master, color) VALUES (?, ?, ?, ?, ?)',
             [@user_name, @user_phone, @date_time, @master, @color]
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

get '/showusers' do
  db = get_db
  @result_set_users = db.execute 'SELECT name, phone, datestamp, master, color FROM users ORDER BY id DESC'
  puts @result_set_users[0]['name']
  erb :showusers
end
