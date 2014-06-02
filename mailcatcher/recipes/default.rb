# パッケージをインストールする
yum_package 'sqlite-devel'

gem_package 'mailcatcher' do
  options '-n /usr/bin'
end

# サービスを起動する
cookbook_file '/etc/rc.d/init.d/mailcatcher' do
  mode     0755
  notifies :restart, 'service[mailcatcher]'
end

service 'mailcatcher' do
  action [ :start, :enable ]
end

include_recipe 'postfix'
