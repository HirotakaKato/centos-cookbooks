# パッケージをインストールする
yum_package 'mysql-server'

# 設定する
template '/etc/my.cnf' do
  mode 0644
  notifies :restart, 'service[mysqld]'
end

# サービスを起動する
service 'mysqld' do
  action [ :start, :enable ]
end

# サービス起動後の設定をする
execute 'echo -e \'\\nn\\n\\n\\n\\n\' | mysql_secure_installation' do
  only_if { Dir.exist?('/var/lib/mysql/test') }
end

# パスワードを設定する
password = node['mysqld']['password']

cnf     = '/root/.my.cnf'
content = "[client]\npassword = #{password}\n"

if not File.exist?(cnf) or File.read(cnf) != content
  tmp = Tempfile.open(['chef-', '-'])
  tmp.write "SET PASSWORD = PASSWORD('#{password}')"
  File.rename(tmp.path, tmp = tmp.path.chop)

  execute "mysql < #{tmp} && rm -f #{tmp}"
end

file cnf do
  mode 0600
  content content
end

# データベースを作成する
node['mysqld']['database'].each do |d|
  tmp = Tempfile.open(['chef-', '-'])
  tmp.write <<-END
    CREATE DATABASE IF NOT EXISTS `#{d[:name]}` DEFAULT CHARACTER SET `#{node['mysqld']['character-set-server']}` COLLATE `#{node['mysqld']['collation-server']}`;
    GRANT ALL ON `#{d[:name].sub('_', '\\_').sub('%', '\\%')}`.* TO '#{d[:user] || d[:name]}'@'#{d[:host] || 'localhost'}' IDENTIFIED BY '#{d[:password] || d[:user] || d[:name]}';
  END
  File.rename(tmp.path, tmp = tmp.path.chop)

  execute "mysql < #{tmp} && rm -f #{tmp}" do
    not_if "mysqlshow '#{d[:name].sub('_', '\\_').sub('%', '\\%')}'"
  end
end
