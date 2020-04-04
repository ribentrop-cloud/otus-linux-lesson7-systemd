# Описание решения



### 1. Создать сервис и unit-файлы для этого сервиса.

Все необходимые действия Vagrant прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service and timer__ 
.  
Необходимые файлы лежат в папке __provisioning_files__:
- watchdog.sh - скрипт для парсинга логов
- watchdog - конфигурационный файл для службы watchdog.service
- watchdog.service - файл юнита systemd типа service для запуска скрипта watchdog.sh как службы
- watchdog.log - лог файл с ключевым словом ALERT для проверки
- watchdog.timer - юнит systemd типа таймер для запуска службы watchdog.service по расписанию

__Проверка:__
1. vagrant up  
2. vagrant ssh  
3. systemctl status watchdog.service - должен быть  __inactive (dead) since..._
4. systemctl status watchdog.timer - должен быть __active (waiting)__
5. sudo tail -f /var/log/messages - скрипт каждые 30 сек оставляет запись "This is __NORMAL WATCHDOG__ servce! I found pattern, Master!"

### 2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.
Все необходимые действия для Vagrant прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service and timer__ 
.  
Необходимые файлы лежат в папке __provisioning_files__:
- httpd@.service - модифицированная копия httpd.service для запуска сервиса с паредачей параметров
- httpd-first, httpd-second - файлы параметров сервисов (httpd-first.service и httpd-second.service), которые ссылаются на разные конфирурации httpd (first.conf и second.conf)
- first.conf,second.conf - конфигурационные файлы для сервисов сервисов httpd-first.service и httpd-second.service, где указаны порты, по которым слушают службы и PID файлы. Для httpd-second.service __выбран порт 81__, т.е. он не блокируется SELinux.  

 __Проверка:__
1. vagrant up  
2. vagrant ssh  
3. systemctl status httpd@first
4. systemctl status httpd@second
5. netstat -an  | grep -Ew "80|81"  
  
__Проверка органичения ресурсов (перенесено собственнолично из п.3., т.к. в п.2. это более наглядно)__.  
1. systemctl status httpd@second - видим ограничения:
```bash
Tasks: 3 (limit: 3)
Memory: 4.5M (limit: 10.0M)
```
2. find /sys/fs/cgroup -name httpd@second.service - видим созданные Cgroups: blkio, pids, memory, cpu,cpuacct. Таким образом, мы ограничили процесс по CPU,MEM,IO,Tasks.



### 3. Создать unit-фаи?л(ы) для сервиса (скрипт с exit 143):
__*реализовать активацию по .path или .socket.__
Все необходимые действия для Vagrant прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service that success on 143 return code__ .  
Необходимые файлы лежат в папке __provisioning_files__:
- watchdog_failure.sh - скрипт для парсинга логов c кодом успешного завершения 143. Обращаю внимание, что ради разнообразия сделал следующее - код выхода скрипта в случе, если в логе __не__ найдена искомая строка (ALERT) равен 1 и в этом случае служба watchdog_failure.service перезапускает скрипт
- watchdog_failure.socket - socket unit для запуска watchdog_failure.service при доступе к порту 9999.
- watchdog_failure.service - для запуска скрипта watchdog_failure.sh. Реализован рестарт службы в случае неуcпешного завершения скрипта:
```sh
Restart=on-failure
RestartSec=10
SuccessExitStatus=143 # - для игнорирования кода 143 как неуспешного
```
- watchdog_failure - конфигурационный файл для службы watchdog_failure.service  
- watchdog_failure.log - лог файл с ОТСУТСТВУЮЩИМ ключевым словом ALERT для проверки  
  
__Проверка:__
1. vagrant up  
2. vagrant ssh  
3. systemctl status watchdog_failure.service - должен быть  __inactive (dead)_
4. systemctl status watchdog_failure.socket  - должен быть  __active (listening)__
5. netstat -an | grep 9999 - видим открытый порт watchdog_failure.socket 
6. date | nc 127.0.0.1 9999 - пишем в порт 9999, нажимаем Ctrl+C
7. sudo tail -f /var/log/messages - скрипт каждые 10 сек (период перезапуска) оставляет запись "This is __FAILURE WATCHDOG__ servce! Pattern not found . Still working , Master!", выходит со статусом 1 и перезапускается через 10 сек. То есть сервис активирован по сокету.
11. sudo echo "ALERT" >> /var/log/watchdog_failure.log - если добавить в  watchdog_failure.log ключевое слово ALERT, то скрипт выйдет по коду 143. Код 143 будет __успешным__ кодом завершения. В логе будет запись "This is __FAILURE WATCHDOG__ servce! I found pattern, Master!"

### 4*. Создать unit-фаи?л(ы) Atlassian Jira.
Все необходимые действия для Vagrant прописаны в Vagrantfile в provision секции: __4. Provisioning to install Jira and make Jira service__ . Необходимые файлы лежат в папке __provisioning_files__:
 - jira.service - файл сервиса jira
Скрипт jira-install.sh рядом с Vagrant file устанавливает Jira.

__Проверка:__
1. vagrant up  
2. vagrant ssh  
3. systemctl status jira.service - должен быть  __active__
