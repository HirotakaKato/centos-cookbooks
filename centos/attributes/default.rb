default['centos']['selinux']     = 'disabled'    # SELinux を無効にする
default['centos']['zone']        = 'Asia/Tokyo'  # タイムゾーンを Asia/Tokyo にする
default['centos']['lang']        = 'ja_JP.UTF-8' # ロケールを ja_JP.UTF-8 にする
default['centos']['tty']         = 1             # 仮想コンソールを 1 個にする（デフォルトは 6 個）
default['centos']['timeout']     = 0             # grub のタイムアウトを 0 秒にする（デフォルトは 5 秒）
default['centos']['crashkernel'] = '0M'          # kdump 用のメモリサイズを 0M にする（デフォルトは auto）

# root 宛メールの転送先
default['centos']['root_forward'] = nil

# プロキシの設定
default['centos']['http_proxy'] = nil
default['centos']['ftp_proxy']  = nil
default['centos']['no_proxy']   = 'localhost'

# 追加するリポジトリ
if node['kernel']['machine'] == 'x86_64'
  default['centos']['repos'] = {
    epel:     'http://ftp.iij.ad.jp/pub/linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm',
    remi:     'http://rpms.famillecollet.com/enterprise/remi-release-6.rpm',
    rpmforge: 'http://apt.sw.be/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm',
  }
else
  default['centos']['repos'] = {
    epel:     'http://ftp.iij.ad.jp/pub/linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm',
    remi:     'http://rpms.famillecollet.com/enterprise/remi-release-6.rpm',
    rpmforge: 'http://apt.sw.be/redhat/el6/en/i386/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.i686.rpm',
  }
end

default['centos']['epel']['enabled']            = 1 # epel リポジトリを有効にする
default['centos']['remi']['enabled']            = 1 # remi リポジトリを有効にする
default['centos']['remi-php55']['enabled']      = 1 # remi-php55 リポジトリを有効にする
default['centos']['rpmforge']['enabled']        = 1 # rpmforge リポジトリを有効にする
default['centos']['rpmforge-extras']['enabled'] = 1 # rpmforge-extras リポジトリを有効にする

# rpmforge-extras リポジトリから tcp_wrappers-libs を除外する
default['centos']['rpmforge-extras']['exclude'] = %w[
  tcp_wrappers
  tcp_wrappers-libs
]

# 除外するパッケージ
default['centos']['exclude'] = {
  'perl-Compress-Raw-Zlib' => 'perl-IO-Compress-Zlib',
}

# インストールするパッケージグループ
default['centos']['groupinstall'] = %w[
  base
  core
  development
  japanese-support
]

# 停止するサービス
default['centos']['disabled_services'] = %w[
  abrt-ccpp
  abrt-oops
  abrtd
  blk-availability
  cpuspeed
  haldaemon
  lvm2-monitor
  mdmonitor
  messagebus
  netfs
  nfslock
  rpcbind
  rpcgssd
  sysstat
  udev-post
]

# deploy ユーザのユーザ名と ssh 公開鍵
default['centos']['deploy']['username']        = 'deploy'
default['centos']['deploy']['authorized_keys'] = nil
