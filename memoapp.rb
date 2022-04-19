# frozen_string_literal: true

require 'sinatra'
require 'csv'

DATA_FILE = 'sample.csv'
DATA_FILE_HEADER = <<~CSV_TEXT
  id,header,body
CSV_TEXT

IO.write DATA_FILE, DATA_FILE_HEADER unless File.exist?(DATA_FILE)

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @title = '一覧'
  @memos = read_data_file
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos/new' do
  memos = read_data_file
  memo_id = memos.size.zero? ? 0 : memos[-1]['id'].to_i + 1
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  CSV.open(DATA_FILE, 'a') do |csv|
    csv << [memo_id, memo_header, memo_body]
  end
  redirect '/memos'
end

get '/memos/:memoid' do
  @title = '詳細'
  @memos = read_data_file
  @memo = find_specific_memo(@memos, params[:memoid])
  erb :show
end

get '/memos/:memoid/edit' do
  @title = '編集'
  @memos = read_data_file
  @memo = find_specific_memo(@memos, params[:memoid])
  erb :edit
end

patch '/memos/:memoid' do # ref
  memos = read_data_file
  memo_id = params[:memo_id]
  memo = find_specific_memo(memos, memo_id)
  index = memos.find_index(memo)
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  memos[index] = [memo_id, memo_header, memo_body]
  File.delete(DATA_FILE)
  IO.write DATA_FILE, DATA_FILE_HEADER
  CSV.open(DATA_FILE, 'a') do |csv|
    memos.each do |m|
      csv << m
    end
  end
  redirect '/memos'
end

delete '/memos/:memoid' do # ref
  memos = read_data_file
  memo_id = params[:memo_id]
  memo = find_specific_memo(memos, memo_id)
  index = memos.find_index(memo)
  memos.delete(index)
  File.delete(DATA_FILE)
  IO.write DATA_FILE, DATA_FILE_HEADER
  CSV.open(DATA_FILE, 'a') do |csv|
    memos.each do |m|
      csv << m
    end
  end
  redirect '/memos'
end

private

def read_data_file
  CSV.read(DATA_FILE, headers: true)
end

def find_specific_memo(memos, memo_id)
  memos.find { |memo| memo['id'] == memo_id }
end
