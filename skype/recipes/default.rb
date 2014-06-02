# パッケージをインストールする
include_recipe 'novnc'
include_recipe 'xvfb::x11vnc'

source = 'http://www.bromosapien.net:8080/others/skype-4.2.0.13-2.el6.i686.rpm'
cache  = File.join(Chef::Config[:file_cache_path], File.basename(source))

user   = 'skype'
home   = "/home/#{user}"

user user do
  home   home
  system true
end

directory home do
  owner user
  group user
  mode  0700
end

directory "#{home}/.vnc" do
  owner user
  group user
  mode  0700
end

file "#{home}/.vnc/passwd" do
  owner user
  group user
  mode  0600
  content node['skype']['passwd']
end

remote_file cache do
  source source
end

yum_package 'skype' do
  source cache
end

# サービスを起動する
cookbook_file '/etc/rc.d/init.d/skype' do
  mode     0755
  notifies :restart, 'service[skype]'
end

%w[ messagebus skype ].each do |s|
  service s do
    action [ :start, :enable ]
  end
end
