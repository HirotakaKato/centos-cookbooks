# パッケージをインストールする
include_recipe 'httpd'

%w[ php php-gd php-mbstring php-opcache ].each do |y|
  yum_package y do
    notifies :restart, 'service[httpd]'
  end
end

yum_package 'php-pecl-xdebug' do
  only_if  { node['php']['xdebug'] }
  notifies :restart, 'service[httpd]'
end

# 設定する
template '/etc/php.ini' do
  mode     0644
  notifies :restart, 'service[httpd]'
end
