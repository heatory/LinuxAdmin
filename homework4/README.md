# Администрирование Linux. ДЗ №4
## Работа с RAID-массивами


## Цель:

Что нужно сделать:
  - Собрать R0/R5/R10 (на выбор);
  - Сломать и починить RAID;
  - Проверить, что рейд собирается при перезагрузке;
  - Создать на созданном RAID-устройстве раздел и файловую систему;
  - Добавить запись в fstab для автомонтирования при перезагрузке.

----------------

### Ход работы:
Первым делом была развернута виртуальная машина на Ubuntu 20.04
Далее были добавлены в систему 4 виртуальных диска.

![Добавленные носители в систему](https://github.com/heatory/LinuxAdmin/blob/master/homework4/info_disks.png "Добавленные носители в систему")

Установлен пакет `mdadm` командой `sudo apt install mdadm`

Создаём RAID10-массив командой `sudo mdadm --create /dev/md0 -l 10 -n 4 /dev/sd{b..e}`

![Собранный RAID10](https://github.com/heatory/LinuxAdmin/blob/master/homework4/create.png "Собранный RAID10")

Проверим состояние, выполнением команд:
```
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

Состояние RAID, обнаруженных в системе:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/cat_start.png "")
![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/info_start.png "")


"Убиваем" один из дисков, например, ***sdc***, следующими командами (номер с 0 изменился на 127 после вынужденной перезагрузки):
```
sudo mdadm /dev/md127 --fail /dev/sdc
sudo mdadm /dev/md127 --remove /dev/sdc
cat /proc/mdstat
sudo mdadm --detail /dev/md127
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/remove.png "")
![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/cat_after_remove.png "")

Состояние второго диска - "***removed***".

Восстанавении структуры:

Добавляем диск, и узнаём его имя:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/add_disk.png "")

Добавляем диск в массив следующими командами:
```
sudo mdadm --add /dev/md127 /dev/sdf
cat /proc/mdstat
sudo mdadm --detail /dev/md127
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/add_disk_mdadm.png "")

Получаем:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/mdadm_info_after_add.png "")


Создадим конфигурационный файл командой `sudo mdadm --detail --scan > /etc/mdadm/mdadm.conf` и выполняем остановку и запуск RAID-массива (номер с 127 сменился на 0, потому что что-то пошло не так, и пришлось произвести все предыдущие действия с нуля): 

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/after_stop.png "")

Перезагружаем машину. 

Результат команды `lsblk` после перезагрузки (номер опять с 0 сменился на 127): 

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/lsbkl_after_restart.png "")

Теперь создадим файловую систему с помощью команды `sudo fdisk /dev/md127`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/create_file_system.png "")

Создадим  файловую систему, для этого воспользуемся командой `sudo mkfs.ext4 /dev/md127p1`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/create_file_system2.png "")

Отредактируем файл `/etc/fstab` добавив строку следующего вида: `UUID=<UUID>	/mnt	ext4	defaults	0	0`

Для того, чтобы узнать UUID диска используем - `sudo blkid /dev/md127p1`.

В результате получили вот это:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework4/for_mount.png "")

Далее монтируем командой `mount -a` и проверяем (`mount`):
```
egor@egor-VirtualBox:~$ mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,noexec,relatime,size=1986900k,nr_inodes=496725,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,nodev,noexec,relatime,size=403088k,mode=755)
/dev/sda5 on / type ext4 (rw,relatime,errors=remount-ro)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
tmpfs on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,mode=755)
cgroup2 on /sys/fs/cgroup/unified type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,name=systemd)
pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
none on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=28,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=13877)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,pagesize=2M)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
/var/lib/snapd/snaps/core18_1880.snap on /snap/core18/1880 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/core18_1932.snap on /snap/core18/1932 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gnome-3-34-1804_36.snap on /snap/gnome-3-34-1804/36 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gnome-3-34-1804_60.snap on /snap/gnome-3-34-1804/60 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gtk-common-themes_1506.snap on /snap/gtk-common-themes/1506 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gtk-common-themes_1514.snap on /snap/gtk-common-themes/1514 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/snap-store_467.snap on /snap/snap-store/467 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/snap-store_498.snap on /snap/snap-store/498 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/snapd_10492.snap on /snap/snapd/10492 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/snapd_8542.snap on /snap/snapd/8542 type squashfs (ro,nodev,relatime,x-gdu.hide)
/dev/sda1 on /boot/efi type vfat (rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,size=403088k,mode=700,uid=1000,gid=1000)
gvfsd-fuse on /run/user/1000/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
/dev/fuse on /run/user/1000/doc type fuse (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
/dev/sr0 on /media/egor/VBox_GAs_6.1.16 type iso9660 (ro,nosuid,nodev,relatime,nojoliet,check=s,map=n,blocksize=2048,uid=1000,gid=1000,dmode=500,fmode=400,uhelper=udisks2)
/dev/md127p1 on /mnt type ext4 (rw,relatime,stripe=256)
```
