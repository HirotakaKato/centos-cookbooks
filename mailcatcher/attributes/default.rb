# iptables にルールを追加する
default['iptables']['tcp'] << { dport: 1080 }

# postfix を設定する
default['postfix']['mydestination'] = ''
default['postfix']['relayhost']     = 'localhost:1025'
