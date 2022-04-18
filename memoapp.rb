# frozen_string_literal: true

require 'sinatra'
require 'csv'

DATA_FILE = 'sample.csv'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @title = '一覧'
  @memos = CSV.read(DATA_FILE)
  erb :index
end

get '/new' do
  @title = '新規作成'
  erb :new
end

post '/new' do
  memos = CSV.read(DATA_FILE)
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  memos_headers = []
  memos.each do |m|
    memos_headers << m[0]
  end

  unless memos_headers.include?(memo_header)
    CSV.open(DATA_FILE, 'a') do |csv|
      csv << [memo_header, memo_body]
    end
  end
  redirect '/'
end

get '/:memo' do
  @title = '詳細'
  @memos = CSV.read(DATA_FILE)
  flatten_memos = @memos.flatten
  index = (flatten_memos.find_index(params[:memo]) / 2).ceil
  @memo = @memos[index]
  erb :show
end

get '/:memo/edit' do
  @title = '編集'
  @memos = CSV.read(DATA_FILE)
  flatten_memos = @memos.flatten
  index = (flatten_memos.find_index(params[:memo]) / 2).ceil
  @memo = @memos[index]
  erb :edit
end

patch '/:memo' do
  memos = CSV.read(DATA_FILE)
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  memos_headers = []
  memos.each do |m|
    memos_headers << m[0]
  end

  unless memos_headers.include?(memo_header)
    flatten_memos = memos.flatten
    index = (flatten_memos.find_index(params[:memo]) / 2).ceil
    memos[index] = [memo_header, memo_body]

    File.delete(DATA_FILE)
    CSV.open(DATA_FILE, 'a') do |csv|
      memos.each do |m|
        csv << m
      end
    end
  end
  redirect '/'
end

delete '/:memo' do
  memo_header = params[:memo_header]
  p memo_header
  memo_body = params[:memo_body]
  p memo_body
  memos = CSV.read(DATA_FILE)
  p memos
  memos.delete([memo_header, memo_body])
  p memos

  File.delete(DATA_FILE)
  CSV.open(DATA_FILE, 'a') do |csv|
    memos.each do |memo|
      csv << memo
    end
  end
  redirect '/'
end
