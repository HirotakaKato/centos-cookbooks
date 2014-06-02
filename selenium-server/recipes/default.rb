# パッケージをインストールする
include_recipe 'openjdk'
include_recipe 'xvfb'

yum_package 'firefox'

%w[ capybara cucumber selenium-webdriver ].each do |g|
  gem_package g do
    options '-n /usr/bin'
  end
end

source = 'http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.1.jar'
cache  = File.join(Chef::Config[:file_cache_path], File.basename(source))

user   = 'selenium'
home   = "/home/#{user}"
file   = "#{home}/selenium-server-standalone.jar"

user user do
  home   home
  system true
end

directory home do
  owner  user
  group  user
  mode   0700
end

directory "#{home}/.fonts" do
  owner  user
  group  user
  mode   0700
end

remote_file cache do
  source source
end

remote_file file do
  owner  user
  group  user
  mode   0600
  source "file://#{cache}"
end

# サービスを起動する
cookbook_file '/etc/rc.d/init.d/selenium-server' do
  mode     0755
  notifies :restart, 'service[selenium-server]'
end

service 'selenium-server' do
  action [ :start, :enable ]
end
