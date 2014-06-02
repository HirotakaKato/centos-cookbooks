# パッケージをインストールする
include_recipe 'munin-node'

yum_package 'munin'

# 設定する
template '/etc/munin/munin.conf' do
  mode     0644
  notifies :restart, 'service[munin-node]'
end

cookbook_file '/etc/httpd/conf.d/munin.conf' do
  mode 0644
end

file '/etc/munin/munin-htpasswd' do
  action :delete
end
