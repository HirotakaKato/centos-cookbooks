# 各パラメータの設定
default['jenkins']['port']           = 8081
default['jenkins']['listen_address'] = 'localhost'
default['jenkins']['args']           = '--prefix=/jenkins'

# インストールするプラグイン
default['jenkins']['plugin'] = %w[ ansicolor clover crap4j git-parameter gitlab-hook php ]
