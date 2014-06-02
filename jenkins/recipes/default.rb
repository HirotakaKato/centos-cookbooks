# パッケージをインストールする
include_recipe 'openjdk'

cookbook_file '/etc/yum.repos.d/jenkins.repo' do
  mode 0644
end

execute 'rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key' do
  not_if 'rpm --quiet -q gpg-pubkey-d50582e6-4a3feef6'
end

yum_package 'jenkins' do
  flush_cache [ :before ]
end

gem_package 'capistrano' do
  options '-n /usr/bin'
end

# 設定する
user = 'jenkins'
home = '/var/lib/jenkins'

directory "#{home}/.ssh" do
  owner user
  group user
  mode  0700
end

cookbook_file "#{home}/.ssh/config" do
  owner user
  group user
  mode  0600
end

template '/etc/sysconfig/jenkins' do
  mode     0600
  notifies :restart, 'service[jenkins]'
end

# サービスを起動する
service 'jenkins' do
  action [ :start, :enable ]
end

# サービス起動後の設定をする
update_center = 'http://updates.jenkins-ci.org/update-center.json'

json    = "#{home}/updates/default.json"
command = "mkdir -p `dirname #{json}` && curl -L #{update_center} | sed -e '1d' -e '$d' > #{json}"

execute command do
  user    user
  group   user
  creates json
end

port   = node['jenkins']['port']
prefix = Array(node['jenkins']['args'].scan(/ ?--prefix=([^ ]+) ?/).first).first
plugin = node['jenkins']['plugin'].join(' ')

jar = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar'
cli = "java -jar #{jar} -s http://localhost:#{port}#{prefix}"

execute "#{cli} install-plugin #{plugin} && #{cli} safe-restart" do
  action     :nothing
  subscribes :run, "execute[#{command}]", :immediately
  user  user
  group user
  retries     10
  retry_delay 10
end
