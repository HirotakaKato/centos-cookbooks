# gitlab の URL
default['gitlab']['external_url'] = "https://#{node['ipaddress']}"

# SSL 証明書のファイル名
default['gitlab']['ssl_certificate']     = '/etc/pki/tls/certs/localhost.crt'
default['gitlab']['ssl_certificate_key'] = '/etc/pki/tls/private/localhost.key'

# 組み込み nginx の location と directive
default['gitlab']['location'] = {
  '/jenkins' => 'proxy_pass http://localhost:8081',
  '/munin'   => 'root /var/www/html',

  '^~ /munin-cgi/munin-cgi-graph' => [
    'access_log off',
    'fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*)',
    'fastcgi_param PATH_INFO $fastcgi_path_info',
    'fastcgi_pass unix:/var/run/munin/fcgi-graph.sock',
    'include /opt/gitlab/embedded/conf/fastcgi_params',
  ],
}

# iptables にルールを追加する
default['iptables']['tcp'] << { dport: 443 }

# munin-node にプラグインの設定を追加する
default['munin-node']['plugin']['postgres'] = "[postgres*]\nuser gitlab-psql"
