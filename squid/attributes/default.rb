# 接続待ちポート
default['squid']['http_port'] = 3128

# キャッシュサイズ
default['squid']['cache_dir'] = 'ufs /var/spool/squid 20480 16 256'
default['squid']['maximum_object_size'] = '5 GB'

# プロキシを設定する
default['centos']['http_proxy'] = "http://localhost:#{node['squid']['http_port']}"

# iptables にルールを追加する
default['iptables']['tcp'] << { dport: node['squid']['http_port'] }
