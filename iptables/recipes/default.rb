# 設定する
template '/etc/sysconfig/ip6tables' do
  only_if { node['iptables']['ip6tables'] }
  mode      0600
  notifies  :restart, 'service[ip6tables]'
end

template '/etc/sysconfig/iptables' do
  mode      0600
  notifies  :restart, 'service[iptables]'
end

# サービスを起動する
service 'ip6tables' do
  action node['iptables']['ip6tables'] ? [ :start, :enable ] : [ :stop, :disable ]
end

service 'iptables' do
  action [ :start, :enable ]
end
