# n0l_infra
n0l Infra repository

#### ex.08

1. Знакомство с  terraform (отсновные команды и понятия). Создание инстанса

2. Входные и выходные переменные и параметризация

3. Provisioners

4. Добавил несколько ssh ключей в коде terraform
   Для добавления нескольких ssh ключей в метаданные всего проекта, их нужно записывать в одну строку без пробелов. (пример ниже). Если через web поменять конфигурацию, затем выполнить terraform apply, то он затрет измения выполненные через web

   ```yaml
   resource "google_compute_project_metadata" "default" {
     metadata = {
       ssh-keys = "appuser:${file(var.public_key_path)}appuser1:${file("/Users/xxx/.ssh/appuser1.pub")}appuser2:${file("/Users/xxx/.ssh/appuser2.pub")}"
     }
   }
   ```

5. Описание через terraform инфраструктуры балансировщика в GCP

ex.07

1. Создание образа c уствновленными пакетами с  помощью packer **ubuntu16.json** (остается только задеплоить приложение)
2.  Настрока файла параметризации **variables.json**
3. Создание полностью готового образа с задеплоенным приложением
4. Команда для  GCP, которая создает VM из образа

#### ex.06

1. Создание инстанса через gcloud и настрока правил firewall
2. Созданы скрипты для настройки системы и деплоя приложения
3. Все скрипты обьединены в один startup script, который можно указать при создании инстанса

testapp_IP = 34.70.106.97
testapp_port = 9292

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

bastion_IP = 35.209.112.226
someinternalhost_IP = 10.128.15.232

#### ex.04

1.  Настройка git hooks вариант pre-commit через https://pre-commit.com/
2. Интеграций github и slack (получение уведомлений в slack)
3. Интеграция travis ci и slack для получения результата проверки

