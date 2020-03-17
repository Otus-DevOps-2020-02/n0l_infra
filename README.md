# n0l_infra
n0l Infra repository

#### ex.04

1.  Настройка git hooks вариант pre-commit через https://pre-commit.com/
2. Интеграций github и slack (получение уведомлений в slack)
3. Интеграция travis ci и slack для получения результата проверки

#### ex.05

1. Создание инстанса через GUI и настрока правил firewall

2. Добавление ssh ключа в проект

3. Подключение чере ssh  к бастион хосту и к хосту за ним. Создание алиаса для быстрого подключения

   ```bash
   $ alias someinternalhost="ssh -i ~/.ssh/appuser -A -J appuser@<ext. IP> appuser@<int. IP>"
   ```

4. Настрока OpenVPN сервера на базе pritunl

5. Настройка валидного сертификата используя сервисы https://letsencrypt.org/ и http://xip.io/ 

6. Для корректной работы:  Справа сверху Settings -> вписать в поле Lets Encrypt Domain - **35.209.112.226.xip.io**

7. Данные для проверки:
   bastion_IP = 35.209.112.226
   someinternalhost_IP = 10.128.15.232

