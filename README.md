# fjord-sinatra-simple

## データベースの作成
- `psql postgres`
- `\i create_database.sql`

## テーブルの作成
- `psql memo_app`
- `\i create_table.sql`

## 実行方法
- `bundle install`
- `bundle exec ruby memoapp.rb`
- http://localhost:4567 にアクセス

## 停止方法
- `ctrl-c`
