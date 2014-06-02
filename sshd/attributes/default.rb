# 接続待ちアドレスとポート
default['sshd']['Port']          = 22
default['sshd']['ListenAddress'] = '0.0.0.0'

# root のログインを許可しない
default['sshd']['PermitRootLogin'] = 'no'

# パスワード認証を許可しない
default['sshd']['PasswordAuthentication'] = 'no'

# iptables にルールを追加する
default['iptables']['tcp'] << { dport: default['sshd']['Port'] }
