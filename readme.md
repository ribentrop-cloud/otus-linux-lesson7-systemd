## Описание решения


### 1. Создать сервис и unit-файлы для этого сервиса.
Необходимые файлы:
- watchdog.sh - скрипт для парсинга логов
- watchdog - конфигурационный файл для службы watchdog.service
- watchdog.service - файл юнита systemd типа service для запуска скрипта watchdog.sh как службы
- watchdog.log - лог файл с ключевым словом ALERT для проверки
- watchdog.timer - юнит systemd типа таймер для запуска службы watchdog.service по расписанию

__Проверка:__
Все необходимые действия для прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service and timer__ 

### 2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.
Необходимые файлы:
- httpd@.service - модифицированная копия httpd.service для запуска сервиса с паредачей параметров
- httpd-first, httpd-second - файлы параметров сервисов (httpd-first.service и httpd-second.service), которые ссылаются на разные конфирурации httpd (first.conf и second.conf)
- first.conf,second.conf - конфигурационные файлы для сервисов сервисов httpd-first.service и httpd-second.service, где указаны порты, по которым слушают службы и PID файлы. Для httpd-second.service __выбран порт 81__, т.е. он не блокируется SELinux.  
__Проверка:__
Все необходимые действия для прописаны в скрипте make-multiple-httpd.sh. Выполенение скрипта прописано в Vagrantfile в provision секции: __Provisioning to create multiple httpd instances__.

### 3. Создать unit-фаи?л(ы) для сервиса (скрипт с exit 143):
Необходимые файлы:
- watchdog_failure.sh - скрипт для парсинга логов c кодом успешного завершения 143. Обращаю внимание, что ради разнообразия сделал следующее - код выхода скрипта в случе, если в логе не найдена искомая строка (ALERT) равен 1 и в этом случае служба watchdog_failure.service перезапускает скрипт
- watchdog_failure.service - для запуска скрипта watchdog_failure.sh. Реализован рестарт службы в случае неувпешного завершения скрипта:
```sh
Restart=on-failure
RestartSec=10
SuccessExitStatus=143 # - для игнорирования кода 143 как неуспешного
```
__Проверка:__
Все необходимые действия для прописаны в Vagrantfile в provision секции: __Provisioning to create watchdog service that success on 143 return code__ .
