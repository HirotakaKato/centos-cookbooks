include_recipe 'centos'

# VMware Tools をインストールする
bash 'vmware-tools' do
  not_if { File.executable?('/usr/bin/vmware-config-tools.pl') }
  code <<-END
    file='VMwareTools-*.tar.gz'
    subdir='vmware-tools-distrib'

    if [ ! -e /dev/sr0 ]; then
      cd /dev
      mknod sr0 b 11 0
      chgrp cdrom sr0
      chmod 660 sr0
    fi

    mount /dev/sr0 /mnt
    tar zxf /mnt/$file -C /tmp
    umount /mnt

    /tmp/$subdir/vmware-install.pl -d
    rm -rf /tmp/$subdir
  END
end

cookbook_file '/etc/rc.d/init.d/vmware-tools' do
  mode 0755
end

service 'vmware-tools' do
  action :enable
end
