# パッケージをインストールする
yum_package 'mod_ssl'

# ssl を設定する
ssl = '/etc/httpd/ssl'
tls = '/etc/pki/tls'

directory ssl do
  mode 0700
end

link "#{ssl}/localhost.crt" do
  to "#{tls}/certs/localhost.crt"
end

link "#{ssl}/localhost.key" do
  to "#{tls}/private/localhost.key"
end

# htpasswd を設定する
htpasswd = '/etc/httpd/htpasswd'

directory htpasswd do
  group 'apache'
  mode  0750
end

# 設定する
template '/etc/httpd/conf/httpd.conf' do
  mode     0644
  notifies :restart, 'service[httpd]'
end

cookbook_file '/etc/httpd/conf.d/ssl.conf' do
  mode     0644
  notifies :restart, 'service[httpd]'
end

template '/etc/httpd/conf.d/virtualhost.conf' do
  mode     0644
  notifies :restart, 'service[httpd]'
end

file '/etc/httpd/conf.d/welcome.conf' do
  action :delete
end

# サービスを起動する
service 'httpd' do
  action [ :start, :enable ]
end
