# パッケージをインストールする
include_recipe 'munin-node'

yum_package 'munin-async'

# munin ユーザを設定する
user  = 'munin'
home  = '/var/lib/munin'
shell = '/usr/share/munin/munin-async'

user user do
  shell shell
end

directory "#{home}/.ssh" do
  owner user
  group user
  mode  0700
end

file "#{home}/.ssh/authorized_keys" do
  only_if { node['munin-asyncd']['authorized_keys'] }
  owner   user
  group   user
  mode    0600
  content Array(node['munin-asyncd']['authorized_keys']).join("\n") + "\n"
end

# サービスを起動する
service 'munin-asyncd' do
  action [ :start, :enable ]
end
