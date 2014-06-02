# 設定する
template '/etc/ssh/sshd_config' do
  mode     0600
  notifies :restart, 'service[sshd]'
end

# サービスを起動する
service 'sshd' do
  action [ :start, :enable ]
end
