require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if logged_in?
      redirect '/tweets'
    else
      erb :'/users/create_user'
    end
  end

  post '/signup' do
    if params[:username] != "" && params[:email] != "" && params[:password] != ""
      user = User.new(username: params[:username], email: params[:email], password: params[:password])
      if user.save
        session[:user_id] = user.id
        redirect '/tweets'
      else
        redirect '/signup'
      end
    else
      redirect '/signup'
    end
  end

  get '/tweets' do
    if logged_in?
      @user = current_user
      erb :'/tweets/tweets'
    else
      redirect '/login'
    end
  end

  get '/login' do
    if logged_in?
      redirect '/tweets'
    else
      erb :'/users/login'
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/tweets'
    else
      redirect '/login'
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect '/login'
    else
      redirect '/'
    end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'/users/show'
  end

  get '/tweets/new' do
    if logged_in?
      erb :'/tweets/create_tweet'
    else
      redirect '/login'
    end
  end

  post '/tweets/new' do
    if params[:content] != ""
      user = current_user
      tweet = Tweet.create(content: params[:content])
      user.tweets << tweet
      user.save
      redirect '/tweets'
    else
      redirect '/tweets/new'
    end
  end

  get '/tweets/:id' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      erb :'/tweets/show_tweets'
    else
      redirect '/login'
    end
  end

  get '/tweets/:id/edit' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      erb :'/tweets/edit_tweets'
    else
      redirect '/login'
    end
  end

  post '/tweets/:id/edit' do
    if params[:content] != ""
      tweet = Tweet.find(params[:id])
      tweet.content = params[:content]
      tweet.save
      redirect '/tweets'
    else
      id = params[:id].to_s
      redirect '/tweets/'+id+'/edit'
    end
  end

  post '/tweets/:id/delete' do
    if logged_in?
      if session[:user_id] == Tweet.find(params[:id]).user_id
        Tweet.find(params[:id]).destroy
      else
        id = params[:id].to_s
        redirect '/tweets/'+id+'/edit'
      end
    else
      id = params[:id].to_s
      redirect '/tweets/'+id+'/edit'
    end
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
end
