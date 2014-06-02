# パッケージをインストールする
yum_package 'squid'

# 設定する
template '/etc/squid/squid.conf' do
  group    'squid'
  mode     0640
  notifies :restart, 'service[squid]'
end

# サービスを起動する
service 'squid' do
  action [ :start, :enable ]
end
