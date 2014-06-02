# パッケージをインストールする
yum_package 'munin-node'

# 設定する
cookbook_file '/etc/munin/munin-node.conf' do
  mode     0644
  notifies :restart, 'service[munin-node]'
end

# プラグインを設定する
node['munin-node']['plugin'].each do |file, content|
  file "/etc/munin/plugin-conf.d/#{file}" do
    mode     0600
    content  Array(content).join("\n") + "\n"
    notifies :restart, 'service[munin-node]'
  end
end

# サービスを起動する
ruby_block 'munin-node' do
  block {}
  notifies :restart, 'service[munin-node]'
end

service 'munin-node' do
  action [ :start, :enable ]
  start_command 'munin-node-configure --shell | sh && service munin-node start'
end
