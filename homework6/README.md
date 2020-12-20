# Администрирование Linux. ДЗ №6
## Практика по Software distribution


## Цель:

1) Создать свой RPM пакет (можно взять свое приложение, либо собрать, например, nginx с определенными опциями);
2) Создать свой репозиторий и разместить там ранее собранный RPM.

----------------

### Ход работы:

Устанавливаем всё необходимое командой `yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/1.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/2.png "")

Загружаем SRPM пакет NGINX для дальнейшей работы над ним командой `wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-2.el7.ngx.src.rpm` и устанавливаем командой `rpm -i nginx-1.18.0-2.el7.ngx.src.rpm`

Так же скачиваем последнюю версию *OpenSSL* и разархивируем архив командами 
```
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
```

В итоге получаем следующий набор файлов и папок в домашнем каталоге:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/5.png "")

Ставим все нужные зависимости командой `yum-builddep rpmbuild/SPECS/nginx.spec`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/6.png "")

Правим файл nginx.spec:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/7.png "")

Устанавливаем gcc для сборки, запускаем саму сборку и смотрим, что пакеты создались после сборки с помощью следующих команд:
```
yum install gcc
rpmbuild -bb rpmbuild/SPECS/nginx.spec
ls -la rpmbuild/RPMS/x86_64/
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/8.png "")

Устанавливаем созданный нами пакет и проверяем, что *nginx* работает:
```
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm
systemctl start nginx
systemctl status nginx
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/9.png "")

Создаём свой репозиторий, для этого создаём папку и копируем туда необходимые пакеты:
```
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://repo.percona.com/centos/7Server/RPMS/noarch/percona-release-1.0-9.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-9.noarch.rpm
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/10.png "")

Инициализируем репозиторий командой `createrepo /usr/share/nginx/html/repo/`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/11.png "")

Добавлеям автоиндексирование в файле конфигурации *nginx*

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/12.png "")

Проверяем корректность конфигурационного файла nginx и перезапускаем командами:
```
nginx -t
nginx -s reload
```

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/13.png "")


Смотрим в браузер:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/14.png "")

Добавляем репозиторий:

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/15.png "")

Убеждаемся, что репозиторий есть командой `yum repolist enabled | grep mai`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/16.png "")

Переустанавливаем nginx командой `yum reinstall nginx`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/17.png "")

Смотрим список всех пакетов, отфильтровав их командой `yum list | grep mai`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/18.png "")

Установим репозиторий percona-release из нашего репозитория `yum install percona-release -y`

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/19.png "")

![](https://github.com/heatory/LinuxAdmin/blob/master/homework6/screenshots/20.png "")