# パッケージをインストールする
source = 'http://downloads-packages.s3.amazonaws.com/centos-6.5/gitlab-6.9.2_omnibus-1.el6.x86_64.rpm'
cache  = File.join(Chef::Config[:file_cache_path], File.basename(source))

remote_file cache do
  source source
end

yum_package 'gitlab' do
  source cache
end

# 設定する
user 'git' do
  home  '/var/opt/gitlab'
  shell '/bin/sh'
end

directory '/etc/gitlab' do
  mode     0775
end

template '/etc/gitlab/gitlab.rb' do
  mode     0600
  notifies :restart, 'service[gitlab]'
end

template '/opt/gitlab/embedded/cookbooks/gitlab/templates/default/nginx-gitlab-http.conf.erb' do
  mode     0664
  notifies :restart, 'service[gitlab]'
end

%w[ Gemfile Gemfile.lock ].each do |c|
  cookbook_file "/opt/gitlab/embedded/service/gitlab-rails/#{c}" do
    mode     0664
    notifies :restart, 'service[gitlab]'
  end
end

bash 'gitlab' do
  only_if { not File.exist?('/etc/pki/tls/private/localhost.key') or not File.exist?('/etc/pki/tls/certs/localhost.crt') }
  umask 077
  code <<-END
    if [ ! -f /etc/pki/tls/private/localhost.key ] ; then
    /usr/bin/openssl genrsa -rand /proc/apm:/proc/cpuinfo:/proc/dma:/proc/filesystems:/proc/interrupts:/proc/ioports:/proc/pci:/proc/rtc:/proc/uptime 1024 > /etc/pki/tls/private/localhost.key 2> /dev/null
    fi

    FQDN=`hostname`
    if [ "x${FQDN}" = "x" ]; then
    FQDN=localhost.localdomain
    fi

    if [ ! -f /etc/pki/tls/certs/localhost.crt ] ; then
    cat << EOF | /usr/bin/openssl req -new -key /etc/pki/tls/private/localhost.key \
      -x509 -days 365 -set_serial $RANDOM \
      -out /etc/pki/tls/certs/localhost.crt 2>/dev/null
--
SomeState
SomeCity
SomeOrganization
SomeOrganizationalUnit
${FQDN}
root@${FQDN}
EOF
    fi
  END
  notifies :restart, 'service[gitlab]'
end

# サービスを起動する
cookbook_file '/etc/rc.d/init.d/gitlab' do
  mode     0755
  notifies :restart, 'service[gitlab]'
end

service 'gitlab' do
  action [ :start, :enable ]
  start_command 'cd /opt/gitlab/embedded/service/gitlab-rails && /opt/gitlab/embedded/bin/bundle && gitlab-ctl reconfigure'
end
