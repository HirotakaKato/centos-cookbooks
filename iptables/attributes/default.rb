# ip6tables は停止する
default['iptables']['ip6tables'] = false

# 許可する TCP 接続
default['iptables']['tcp'] = [
#  {
#    src:    '', # 送信元 addrs    例 192.168.0.0/24
#    sports: '', # 送信元 ports    （未指定時は任意）
#    dst:    '', # 接続待ち addrs  例 192.168.0.1
#    dports: '', # 接続待ち ports  例 22,80,443
#  },
]

# 許可する UDP 接続
default['iptables']['udp'] = []
