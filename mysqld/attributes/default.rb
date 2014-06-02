# 各パラメータの設定
default['mysqld']['bind-address']         = 'localhost'
default['mysqld']['port']                 = 3306
default['mysqld']['character-set-server'] = 'utf8'
default['mysqld']['collation-server']     = 'utf8_bin'

# mysqld の root パスワード
default['mysqld']['password'] = 'root'

# 作成するデータベース
default['mysqld']['database'] = [
#  {
#    name: '',     # データベース名
#    user: '',     # ユーザ名
#    host: '',     # アクセスを許可するホスト
#    password: '', # パスワード
#  },
]

# iptables にルールを追加する
default['iptables']['tcp'] << { dport: node['mysqld']['port'] } if node['mysqld']['bind-address'] != 'localhost'

# munin-node にプラグインの設定を追加する
default['munin-node']['plugin']['mysql'] = "[mysql*]\nenv.mysqlpassword #{node['mysqld']['password']}"
