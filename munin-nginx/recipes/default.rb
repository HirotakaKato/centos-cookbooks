# パッケージをインストールする
include_recipe 'munin'

yum_package 'munin-nginx'

# 設定する
user 'nginx' do
  comment 'Nginx web server'
  home    '/var/lib/nginx'
  shell   '/sbin/nologin'
  system  true
end

template '/etc/rc.d/init.d/munin-fcgi-graph' do
  mode     0755
  notifies :restart, 'service[munin-fcgi-graph]'
end

# サービスを起動する
service 'munin-fcgi-graph' do
  action [ :start, :enable ]
end
