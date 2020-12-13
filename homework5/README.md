# Администрирование Linux. ДЗ №5
## Работа с lvm


## Цель:
Практика c LVM

----------------

### Ход работы:
Развернута виртуальная машина под управленем ubuntu 20.04
Далее были добавлены в систему 5 виртуальных дисков по 512 Mb каждый.

Установил *lvm* командой `sudo apt install lvm2 -y`

Проверил состояние текущей машины при помощи команд 
```
lsblk
sudo lvmdiskscan
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/1.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/2.png "")

Добавил диск, как PV, последовательностью следующих команд: 

```
sudo pvcreate /dev/sdb
sudo pvdisplay
sudo lvmdiskscan
sudo pvs
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/3.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/4.png "")

Создал VG на базе PV:

```
sudo vgcreate mai /dev/sdb
sudo vgdisplay -v mai
sudo vgs
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/5.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/6.png "")

Далее создал логический том: 

```
sudo lvcreate -l+100%FREE -n first mai
sudo lvdisplay
sudo lvs
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/7.png "")


Потом создал файловую систему, смонтировал и проверил её:

```
sudo mkfs.ext4 /dev/mai/first
sudo mount /dev/mai/first /mnt
sudo mount
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/8.png "")

```
egor@egor-VirtualBox:~$ sudo mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,noexec,relatime,size=1642880k,nr_inodes=410720,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,nodev,noexec,relatime,size=334216k,mode=755)
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
cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=28,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=13735)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,pagesize=2M)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
/var/lib/snapd/snaps/snapd_8542.snap on /snap/snapd/8542 type squashfs (ro,nodev,relatime,x-gdu.hide)
/dev/sda1 on /boot/efi type vfat (rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,size=334212k,mode=700,uid=1000,gid=1000)
gvfsd-fuse on /run/user/1000/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
/dev/fuse on /run/user/1000/doc type fuse (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
/var/lib/snapd/snaps/core18_1880.snap on /snap/core18/1880 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gnome-3-34-1804_36.snap on /snap/gnome-3-34-1804/36 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/gtk-common-themes_1506.snap on /snap/gtk-common-themes/1506 type squashfs (ro,nodev,relatime,x-gdu.hide)
/var/lib/snapd/snaps/snap-store_467.snap on /snap/snap-store/467 type squashfs (ro,nodev,relatime,x-gdu.hide)
/dev/mapper/mai-first on /mnt type ext4 (rw,relatime)
```


Cоздал файл, который занял всё пространство:
```
sudo dd if=/dev/zero of=/mnt/test.file bs=1M count=1500 status=progress
sudo df -h
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/9.png "")

Произвел расширение логического тома:
```
sudo pvcreate /dev/sdc
sudo vgextend mai /dev/sdc
sudo lvextend -l+100%FREE /dev/mai/first
sudo lvdisplay
sudo lvs
sudo df -h
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/10.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/11.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/12.png "")

Расширил файловую систему:
```
sudo resize2fs /dev/mai/first
sudo df -h
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/13.png "")

Далее уменьшил файловую систему и LV (т.к. команда уменьшения файловой системы ругалась, что указываемый размер меньше допустимо минимально, выполнил команду с флагом -f (force)):
```
sudo umount /mnt
sudo fsck -fy /dev/mai/first
sudo resize2fs -f /dev/mai/first 650M
sudo mount /dev/mai/first /mnt
sudo df -h
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/14.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/15.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/16.png "")

Далее создал несколько файлов и сделал снимок:
```
sudo touch /mnt/file{1..5}
ls /mnt
sudo lvcreate -L 100M -s -n snapsh /dev/mai/first
sudo lvs
sudo lsblk
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/17.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/18.png "")


Удалил несколько файлов: 
```
sudo rm -f /mnt/file{1..3}
ls /mnt
```

Результат:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/19.png "")

Восстановил файлы используя ранее созданный снимок

Удостоверился, что в снимке есть файлы:
```
sudo mkdir /snap
sudo mount /dev/mai/snapsh /snap
ls /snap
sudo umount /snap
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/20.png "")

Отмонтировал файловую систему и произведем слияние:
```
sudo umount /mnt
sudo lvconvert --merge /dev/mai/snapsh
sudo mount /dev/mai/first /mnt
ls /mnt
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/21.png "")

Добавил ещё PV, VG и создал LV-зеркало:
```
sudo pvcreate /dev/sd{d,e}
sudo vgcreate vgmirror /dev/sd{d,e}
sudo lvcreate -l+80%FREE -m1 -n mirror1 vgmirror
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/22.png "")


Смотрим синхронизацию:
```
sudo lvs
sudo lsblk
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework5/screenshots/23.png "")

```
egor@egor-VirtualBox:~$ sudo lsblk
NAME                     MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0                      7:0    0  29,9M  1 loop /snap/snapd/8542
loop1                      7:1    0    55M  1 loop /snap/core18/1880
loop2                      7:2    0 255,6M  1 loop /snap/gnome-3-34-1804/36
loop3                      7:3    0  62,1M  1 loop /snap/gtk-common-themes/1506
loop4                      7:4    0  49,8M  1 loop /snap/snap-store/467
sda                        8:0    0    10G  0 disk 
├─sda1                     8:1    0   512M  0 part /boot/efi
├─sda2                     8:2    0     1K  0 part 
└─sda5                     8:5    0   9,5G  0 part /
sdb                        8:16   0   512M  0 disk 
└─mai-first              253:0    0   652M  0 lvm  /mnt
sdc                        8:32   0   512M  0 disk 
└─mai-first              253:0    0   652M  0 lvm  /mnt
sdd                        8:48   0   512M  0 disk 
├─vgmirror-mirror1_rmeta_0
│                        253:1    0     4M  0 lvm  
│ └─vgmirror-mirror1     253:5    0   404M  0 lvm  
└─vgmirror-mirror1_rimage_0
                         253:2    0   404M  0 lvm  
  └─vgmirror-mirror1     253:5    0   404M  0 lvm  
sde                        8:64   0   512M  0 disk 
├─vgmirror-mirror1_rmeta_1
│                        253:3    0     4M  0 lvm  
│ └─vgmirror-mirror1     253:5    0   404M  0 lvm  
└─vgmirror-mirror1_rimage_1
                         253:4    0   404M  0 lvm  
  └─vgmirror-mirror1     253:5    0   404M  0 lvm  
sdf                        8:80   0   512G  0 disk 
sr0                       11:0    1  1024M  0 rom  

```
