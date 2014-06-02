# 設定する
template '/etc/postfix/main.cf' do
  mode     0644
  notifies :restart, 'service[postfix]'
end

# サービスを起動する
service 'postfix' do
  action [ :start, :enable ]
end
