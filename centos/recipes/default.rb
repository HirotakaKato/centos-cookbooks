# SELinux を設定する
template '/etc/selinux/config' do
  mode 0644
end

execute "setenforce #{node['centos']['selinux'] == 'enforcing' ? 1 : 0}" do
  action     :nothing
  subscribes :run, 'template[/etc/selinux/config]', :immediately
end

service 'auditd' do
  action node['centos']['selinux'] == 'disabled' ? [ :stop, :disable ] : [ :start, :enable ]
end

# タイムゾーンを設定する
file '/etc/sysconfig/clock' do
  only_if { node['centos']['zone'] }
  mode    0644
  content %Q(ZONE="#{node['centos']['zone']}"\n)
end

remote_file '/etc/localtime' do
  mode    0644
  source  'file:///usr/share/zoneinfo/' + node['centos']['zone']
end

# ロケールを設定する
file '/etc/sysconfig/i18n' do
  only_if { node['centos']['lang'] }
  mode    0644
  content %Q(LANG="#{node['centos']['lang']}"\n)
end

# 仮想コンソールの個数を設定する
file '/etc/sysconfig/init' do
  mode    0644
  content `sed 's/^\\(ACTIVE_CONSOLES=\\/dev\\/tty\\).*$/\\1[1-#{node['centos']['tty']}]/' #{name}`
end

# grub のタイムアウトと kdump 用のメモリサイズを設定して、起動時のグラフィカル表示を無効にする
file '/boot/grub/grub.conf' do
  mode    0600
  content `sed -e 's/^\\(timeout=\\).*$/\\1#{node['centos']['timeout']}/' -e 's/ \\(crashkernel=\\)[^ ]*  \\?/ \\1#{node['centos']['crashkernel']} /' -e 's/ rhgb / /' #{name}`
end

yum_package 'kexec-tools'

service 'kdump' do
  action node['centos']['crashkernel'] == '0M' ? :disable : :enable
end

# root 宛メールを転送する
file '/root/.forward' do
  only_if { node['centos']['root_forward'] }
  mode    0600
  content Array(node['centos']['root_forward']).join("\n") + "\n"
end

# プロキシを設定する
%w[ proxy.csh proxy.sh ].each do |t|
  template "/etc/profile.d/#{t}" do
    only_if { node['centos']['http_proxy'] }
    mode    0644
  end
end

ruby_block 'centos' do
  action     :nothing
  subscribes :run, 'template[/etc/profile.d/proxy.sh]', :immediately
  block do
    ENV['http_proxy'] = node['centos']['http_proxy']
    ENV['ftp_proxy']  = node['centos']['ftp_proxy'] || node['centos']['http_proxy']
    ENV['no_proxy']   = node['centos']['no_proxy']

    ENV['HTTP_PROXY'] = ENV['http_proxy']
    ENV['FTP_PROXY']  = ENV['ftp_proxy']
    ENV['NO_PROXY']   = ENV['no_proxy']
  end
end

# リポジトリを追加する
node['centos']['repos'].each do |repo, source|
  cache = File.join(Chef::Config[:file_cache_path], File.basename(source))

  remote_file cache do
    source source
  end

  yum_package "#{repo}-release" do
    source cache
    flush_cache [ :after ]
  end

  template "/etc/yum.repos.d/#{repo}.repo" do
    mode 0644
  end
end

# パッケージを除外する
node['centos']['exclude'].each do |exclude, obsolete|
  yum_package exclude do
    only_if "rpm --quiet -q #{obsolete}"
    action  :remove
  end
end

template '/etc/yum.repos.d/CentOS-Base.repo' do
  mode 0644
end

# パッケージをアップデートして、サービスを停止する
bash 'centos' do
  action     :nothing
  subscribes :run, 'template[/etc/yum.repos.d/CentOS-Base.repo]', :immediately
  code <<-END
    yum -d0 -e0 -y groupinstall #{node['centos']['groupinstall'].join(' ')}
    yum -d0 -e0 -y update
    service postfix restart

    for s in #{node['centos']['disabled_services'].join(' ')}; do
      service $s stop 2> /dev/null || true
      chkconfig --level 0123456 $s off 2> /dev/null || true
    done
  END
end

# deploy ユーザを作成する
if node['centos']['deploy']['authorized_keys']
  user            = node['centos']['deploy']['username']
  home            = "/home/#{user}"
  authorized_keys = "#{home}/.ssh/authorized_keys"

  user user

  directory home do
    owner user
    group user
    mode  0755
  end

  directory File.dirname(authorized_keys) do
    owner user
    group user
    mode  0700
  end

  file authorized_keys do
    owner   user
    group   user
    mode    0600
    content Array(node['centos']['deploy']['authorized_keys']).join("\n") + "\n"
  end
end
