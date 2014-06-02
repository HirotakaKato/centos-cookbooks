# バーチャルホストの設定
default['httpd']['virtualhost'] = [
#  {
#    virtualhost: '*:80',
#
#    ServerName: '',
#    ServerAlias: nil,
#
#    redirect: false,
#
#    DocumentRoot: '',
#    ScriptAlias: [],
#    Alias: [],
#    ProxyPass: [],
#
#    ssl: false,
#    chain: false,
#
#    htpasswd: false,
#  },
]

# server-status の設定
default['httpd']['server-status'] = true

# iptables にルールを追加する
default['iptables']['tcp'] << { dports: '80,443' }
