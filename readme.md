## Описание решения
### Написать watchdog.timer
[root@knox journal]# cat /etc/sysconfig/watchdog
```sh
WORD="ALERT"
LOG=/var/log/watchdog.log
```
[root@knox journal]# cat /var/log/watchdog.log
```sh
user1.normal,4
user3,nomal,6
user6,ALERT,7
user3,normal,2
```
[root@knox _hw]# cat watchdog.sh
```sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
        logger "$DATE : I found, Master!"
else
        exit 0
fi
```
Example run:
```sh
./watchdog.sh ALERT /var/log/watchdog.log
```

vim /etc/systemd/system/watchdog.service
```sh
[Unit]
Description=My watchdog service

[Service]
Type=oneshot
#PIDFile=/root/_hw/service.pid
#WorkingDirectory=/work/www/myunit/current
#User=root

EnvironmentFile=/etc/sysconfig/watchdog
ExecStart=/bin/bash /root/_hw/watchdog.sh $WORD $LOG

[Install]
WantedBy=multi-user.target
```

vim /etc/systemd/system/watchdog.timer
```sh
[Unit]
Description=add description

[Timer]
# Run every one hour or one munite
OnUnitActiveSec=30
AccuracySec=1
Unit=watchdog.service

[Install]
WantedBy=multi-user.target

```
systemctl start watchdog.timer
### Написать сервис с опциями

[root@knox _hw]# cat /usr/lib/systemd/system/httpd@.service
```sh
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%i
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
[root@knox _hw]# cat  /etc/sysconfig/httpd-first
```sh
OPTIONS=-f conf/first.conf
```
[root@knox _hw]# cat  /etc/sysconfig/httpd-second
```sh
OPTIONS=-f conf/second.conf
```
 vim /etc/httpd/conf/second.conf (обратить внимание на порт)
 ```sh
 Listen 8080
PidFile /var/run/http-second.pid
 ```
 cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
 
 ============================================================
 Домашнее задание
Systemd
Цель: Цели: - Понимать назначение systemd - Уметь создавать unit-файлы - Знать где искать информацию о systemd и его компонентах Результат ДЗ: - Создать разные типы unit-файлов - Использовать шаблоны unit-файлов - Задать разные типы параметров (переменные, ограничения, код завершения) - Переписать SysV скрипт на unit-файл
Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):
1. Создать сервис и unit-файлы для этого сервиса:
- сервис: bash, python или другой скрипт, который мониторит log-файл на наличие ключевого слова;
- ключевое слово и путь к log-файлу должны браться из /etc/sysconfig/ (.service);
- сервис должен активироваться раз в 30 секунд (.timer).

2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.

3. Создать unit-фаи?л(ы) для сервиса:
- сервис: Kafka, Jira или любой другой, у которого код успешного завершения не равен 0 (к примеру, приложение Java или скрипт с exit 143);
- ограничить сервис по использованию памяти;
- ограничить сервис ещё по трём ресурсам, которые не были рассмотрены на лекции;
- реализовать один из вариантов restart и объяснить почему выбран именно этот вариант.
* реализовать активацию по .path или .socket.

4*. Создать unit-фаи?л(ы):
- сервис: демо-версия Atlassian Jira;
- переписать(!) скрипт запуска на unit-файл.
Критерии оценки: основная часть обязательна
задание со звездочкой +1 балл
