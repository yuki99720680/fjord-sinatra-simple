# frozen_string_literal: true

require 'sinatra'
require 'pg'

SELECT_ALL_MEMOS_SQL = 'SELECT * FROM memos ORDER BY id ASC'
SELECT_SPECIFIC_MEMOS_SQL = 'SELECT * FROM memos WHERE id = $1' # [memo_id]
INSERT_MEMOS_SQL = 'INSERT INTO memos (header, body) VALUES ($1, $2)' # [memo_header, memo_body]
UPDATE_SPECIFIC_MEMOS_SQL = 'UPDATE memos SET header = $1, body = $2 WHERE id = $3' # [memo_header, memo_body, memo_id]
DELETE_SPECIFIC_MEMOS_SQL = 'DELETE FROM memos WHERE id = $1' # [memo_id]

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
  @memos = execute_select_all_memos_sql
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos/new' do
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  execute_bind_sql(INSERT_MEMOS_SQL, [memo_header, memo_body])
  redirect '/memos'
end

get '/memos/:memoid' do
  @title = '詳細'
  memo_id = params[:memoid]
  @memo = execute_bind_sql(SELECT_SPECIFIC_MEMOS_SQL, [memo_id]).first
  erb :show
end

get '/memos/:memoid/edit' do
  @title = '編集'
  memo_id = params[:memoid]
  @memo = execute_bind_sql(SELECT_SPECIFIC_MEMOS_SQL, [memo_id]).first
  erb :edit
end

patch '/memos/:memoid' do
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  memo_id = params[:memoid]
  execute_bind_sql(UPDATE_SPECIFIC_MEMOS_SQL, [memo_header, memo_body, memo_id])
  redirect '/memos'
end

delete '/memos/:memoid' do
  memo_id = params[:memoid]
  execute_bind_sql(DELETE_SPECIFIC_MEMOS_SQL, [memo_id])
  redirect '/memos'
end

private

def connect_db
  PG.connect(dbname: 'memo_app')
end

def execute_select_all_memos_sql
  memos_db = connect_db
  memos_db.exec(SELECT_ALL_MEMOS_SQL)
end

def execute_bind_sql(sql, array)
  memos_db = connect_db
  memos_db.exec(sql, array)
end
