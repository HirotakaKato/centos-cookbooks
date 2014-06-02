# パッケージをインストールする
include_recipe 'mysqld'
include_recipe 'php'

yum_package 'php-mysqlnd' do
  notifies :restart, 'service[httpd]'
end
