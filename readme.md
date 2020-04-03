# Описание решения



### 1. Создать сервис и unit-файлы для этого сервиса.

Все необходимые действия Vagrant прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service and timer__ 
Необходимые файлы лежат в папке __provisioning_files__:
- watchdog.sh - скрипт для парсинга логов
- watchdog - конфигурационный файл для службы watchdog.service
- watchdog.service - файл юнита systemd типа service для запуска скрипта watchdog.sh как службы
- watchdog.log - лог файл с ключевым словом ALERT для проверки
- watchdog.timer - юнит systemd типа таймер для запуска службы watchdog.service по расписанию

__Проверка:__
1. vagrant up  
2. vagrant ssh  
3. cat  /etc/systemd/system/watchdog.service
4. cat  /etc/systemd/system/watchdog.timer
5. systemctl status watchdog.service - должен быть  __inactive (dead) since..._
6. systemctl status watchdog.timer - должен быть __active (waiting)__
7. cat /etc/sysconfig/watchdog
8. sudo tail -f /var/log/messages - скрипт каждые 30 сек оставляет запись "This is __NORMAL WATCHDOG__ servce! I found pattern, Master!"

### 2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.
Все необходимые действия для Vagrant прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service and timer__ 
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
3. cat  /etc/systemd/system/watchdog_failure.service  
4. cat  /etc/systemd/system/watchdog_failure.socket
5. systemctl status watchdog_failure.service - должен быть  __inactive (dead)_
6. systemctl status watchdog_failure.socket  - socket unit запущен
7. netstat -an | grep 9999 - видим открытый порт watchdog_failure.socket 
7. cat /etc/sysconfig/watchdog_failure
8. date | nc 127.0.0.1 9999 - кидаем в порт 9999 дату, нажимаем Ctrl+C и смотрим лог
9. sudo tail -f /var/log/messages - скрипт каждые 10 сек (период перезапуска) оставляет запись "This is __FAILURE WATCHDOG__ servce! Pattern not found . Still working , Master!"  и выходит со статусом 1
9. sudo echo "ALERT" >> /var/log/watchdog_failure.log - если добавить в  watchdog_failure.log ключевое слово ALERT, то скрипт выйдет по коду 143. Код 143 будет успешным кодом завершения. В логе будет запись "This is __FAILURE WATCHDOG__ servce! I found pattern, Master!"
