# frozen_string_literal: true

require 'sinatra'
require 'pg'

SELECT_ALL_MEMOS_SQL = <<~SQL
  SELECT * FROM memos ORDER BY id ASC;
SQL

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
  @memos = sql_execution(SELECT_ALL_MEMOS_SQL)
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos/new' do
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  insert_memos_sql = build_insert_memos_sql(memo_header, memo_body)
  sql_execution(insert_memos_sql)
  redirect '/memos'
end

get '/memos/:memoid' do
  @title = '詳細'
  memo_id = params[:memoid]
  select_specific_memos_sql = build_select_specific_memos_sql(memo_id)
  memos = sql_execution(select_specific_memos_sql)
  @memo = memos.first
  erb :show
end

get '/memos/:memoid/edit' do
  @title = '編集'
  memo_id = params[:memoid]
  select_specific_memos_sql = build_select_specific_memos_sql(memo_id)
  memos = sql_execution(select_specific_memos_sql)
  @memo = memos.first
  erb :edit
end

patch '/memos/:memoid' do
  memo_header = params[:memo_header]
  memo_body = params[:memo_body]
  memo_id = params[:memoid]
  update_specific_memos_sql = build_update_specific_memos_sql(memo_header, memo_body, memo_id)
  sql_execution(update_specific_memos_sql)
  redirect '/memos'
end

delete '/memos/:memoid' do
  memo_id = params[:memoid]
  delete_specific_memos_sql = build_delete_specific_memos_sql(memo_id)
  sql_execution(delete_specific_memos_sql)
  redirect '/memos'
end

private

def sql_execution(sql)
  memos_db = PG.connect(dbname: 'memo_app')
  memos_db.exec(sql)
end

def build_select_specific_memos_sql(memo_id)
  "SELECT * FROM memos WHERE id = #{memo_id};"
end

def build_insert_memos_sql(memo_header, memo_body)
  "INSERT INTO memos (header, body) VALUES ('#{memo_header}', '#{memo_body}');"
end

def build_update_specific_memos_sql(memo_header, memo_body, memo_id)
  "UPDATE memos SET header = '#{memo_header}', body = '#{memo_body}' WHERE id = #{memo_id};"
end

def build_delete_specific_memos_sql(memo_id)
  "DELETE FROM memos WHERE id = #{memo_id};"
end
