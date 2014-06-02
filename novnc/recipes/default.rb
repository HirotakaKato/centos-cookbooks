# パッケージをインストールする
yum_package 'novnc'

# サービスを起動する
cookbook_file '/etc/rc.d/init.d/novnc' do
  mode     0755
  notifies :restart, 'service[novnc]'
end

service 'novnc' do
  action [ :start, :enable ]
end
