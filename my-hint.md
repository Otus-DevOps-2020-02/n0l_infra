# Packer

Packer — это инструмент для создания одинаковых образов ОС для различных платформ из одного описания.

Достаточно давно [Патрик Дебоиз](http://www.jedi.be/blog/) (это человек, который придумал термин DevOps) написал [Veewee](https://github.com/jedi4ever/veewee) — инструмент, который позволяет автоматически создавать образа для VirtualBox, KVM и VMWare.

Packer пошел дальше, и позволяет делать то же самое для распространенных облачных провайдеров: [Amazon](http://www.packer.io/docs/builders/amazon.html),[DigitalOcean](http://www.packer.io/docs/builders/digitalocean.html), [OpenStack](http://www.packer.io/docs/builders/openstack.html) и [GCE](http://www.packer.io/docs/builders/googlecompute.html). Также Packer позволяет создавать контейнеры для [Docker](https://www.docker.io/).

Взято отсюда: https://habr.com/ru/company/express42/blog/212085/

#### Установка и натройка

Инструкция поустановке https://packer.io/downloads.html

Распакуйте скачанный zip архив и поместите бинарный файл в директорию, путь до которой содержится в переменной окружения PATH.

```bash
$ packer -v
```

Для управления ресурсами GCP через сторонние приложения, такие как Packer и Terraform, нам нужно предоставить этим инструментам информацию (credentials) для аутентификации и управления ресурсами GCP нашего акаунта.

Application Default Credentials (ADC)

Установка ADC позволяет приложениям, работающим с GCP ресурсами и использующим Google API библиотеки, управлять ресурсами GCP через авторизованные API вызовы, используя credentials вашего пользователя.

Создайте АDC:

```bash
$ gcloud auth application-default login
```

#### Пример шаблона

Шаблоны хранятся в формате .json.

Если **builders** секция отвечает за создание виртуальной машины для билда и создание машинного образа в GCP, то секция **provisioners** позволяет устанавливать нужное ПО, производить настройки системы и конфигурацию приложений на созданной VM.

Вот примера шаблона:

```json
{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "infra-189607",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "ubuntu-1604-lts",
            "zone": "us-central1-f",
            "ssh_username": "appuser",
            "machine_type": "f1-micro"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```

- type: "googlecompute" - что будет создавать виртуальную машину для билда образа (в нашем случае Google Compute Engine)

- project_id: "infra-00001" - id вашего проекта

- image_family: "reddit-base" - семейство образов к которому будет принадлежать новый образ

- image_name: "reddit-base-{{timestamp}}" - имя создаваемого образа
- source_image_family: "ubuntu-1604-lts" - что взять за базовый образ для нашего билда

- zone: "europe-west1-b" - зона, в которой запускать VM для билда образа
- ssh_username: "appuser" - временный пользователь, который будет создан для подключения к VM во время билда и выполнения команд провижинера (о нем поговорим ниже)
- machine_type: "f1-micro" - тип инстанса, который запускается для билда
- Используем [shell provisioner](https://packer.io/docs/provisioners/shell.html), который позволяет запускать bash команды на запущенном инстансе.
- Опция execute_command позволяет указать, каким способом будет запускаться скрипт. Т.к. команды по установке требуют sudo, то мы указываем, что запускать скрипт следует с sudo

```bash
# проверить на наличие ошибок
$ packer validate  -var-file variables.json ./ubuntu16.json
# запустить сборку образа
$ packer build -var-file variables.json ubuntu16.json
```

#### Параметризация параметров

Файл **variables.json** нужно добавлять в gitignore а для примера создавать файл **variables.json.example** c вымышленными заначениями

Значения параметров хранятся в файле **variables.json**

```json
{
  "project_id": "infra-00001",
  "source_image_family": "ubuntu-1604-lts",
  "machine_type": "f1-micro"
}
```

А сами значения параметров в файле меняются на 

```json
{
"project_id": "{{user `project_id`}}",
"source_image_family": "{{user `source_image_family`}}",
"machine_type": "{{user `machine_type`}}"
}
```

Готовый образ можно использовать для быстрого развертывания VM

# Google Cloud Platform

Облачная платформа от google

Для теста потребуется учетка и пластиковая карта (виртуальные вроде не подходят)
Также у меня не сработало с только что созданными учетками.

https://console.cloud.google.com/

#### Установака gcloud

https://cloud.google.com/sdk/docs/

Я установил в каталог **/opt/google-cloud-sdk/** якобы тут должны лежать программы пользователя установленные не из репозитрия

Также нужно обновить пути:

```bash
# The next line updates PATH for the Google Cloud SDK.
$ source '[path-to-my-home]/google-cloud-sdk/path.bash.inc'
# The next line enables bash completion for gcloud.
$ source '[path-to-my-home]/google-cloud-sdk/completion.bash.inc'
```

#### Команды

```bash
gcloud auth list
gcloud info
gcloud inint
# создать витруальную машину
gcloud compute instances create instance-from-gcloud-cli \
  --boot-disk-size=10GB \
  --image=ubuntu-1604-xenial-v20170815a \
  --image-project=ubuntu-os-cloud \
  --machine-type=f1-micro \
  --labels=role=willberemovedin24h \
  --preemptible \
  --restart-on-failure \
  --zone=europe-west1-d
# появится два предупреждения, одно про меделенную работу дисков размером меньше 200 ГБ, второе про то что старые образ будет заменен на более свежий

#Можно вместо --image указывать --image-family, что дает большую свободу (не нужно искать какой образ последний)
  --image-family ubuntu-1604-lts \
# пример списка хостов
gcloud compute instances list
# чтобы указать startup script нужно добавить опцию
  --metadata-from-file startup-script=path/to/file
# так можно загрузить startup script из интернета
  --metadata startup-script-url=gs://bucket/startupscript.sh
# удалить инстанс
gcloud compute instances delete INSTANCE_NAMES
# рыба
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=f1-micro \
  --zone=us-central1-f \
  --tags=puma-server,http-server \
  --restart-on-failure \
  --boot-disk-type=pd-standard \
  --metadata-from-file startup-script=path/to/file
```

#### Bucket

Хранилище до 5ТБ, которое доступно из любого проекта. Подходит для организации данных

```bash
# Создаем бакет(емкость для данных), имя должно быть уникальным!!!
gsutil mb gs://otus-test

# Смотрим что есть
gsutil ls               

# Копируем файл в Storage
gsutil cp Storage-test.txt gs://otus-test/

# Смотрим содержимое
gsutil cat gs://otus-test/Storage-test.txt

# Копируем к себе файл
gsutil cp gs://otus-test/Storage-test.txt local.Storage-test.txt
```

#### Firewall

```bash
# создать правило ис комадоной строки
gcloud compute firewall-rules create default-puma-server1  --allow=tcp:9292   --source-ranges=0.0.0.0/0   --target-tags=puma-server
```

# SSH

Сгенегрировать ключ для пользователя appuser с пустым паролем

```bash
$ ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""
$ ssh -i ~/.ssh/appuser appuser@<внешний IP VM> - подключиться к внешней VM -i указать серт
$ ssh-add -L - перечисляет параметры публичных ключей всех идентификаторов, представленных агентом в настоящий момент
$ ssh-add ~/.ssh/appuser - Добавить приватный ключ в агент авторизации
$ ssh -i ~/.ssh/appuser -A appuser@<внешний IP VM> - -A принудительно использовать SSH Agent Forwarding (посмотреть как настроить в конфиге)
```

#### Настройка подключения в одну комманду:
```bash
$ alias someinternalhost="ssh -i ~/.ssh/appuser -A -J appuser@<ext. IP> appuser@<int. IP>"
```

# Travis CI

Все настройки travis хранаятся в файле .travis.yml в корне репозитория. Для успешной интеграции его со sklack потребуется

1. https://slack.com/intl/en-ru/help/articles/232289568-GitHub-for-Slack
2. /github subscribe Otus-DevOps-2020-02/<GITHUB_USER>_infra commits:all
3. В slack разрешить отправку сообщений о статусе билда

#### Хранение секретов

Секрет хранится в зашифрованном виде в файле .travis.yml. Для создания секрета для интеграции slack и travis:

```bash
$ gem install travis
$ travis <login> --com
$ travis encrypt "devops-team-otus:<ваш_токен>#<имя_вашего_канала>" \ --add notifications.slack.rooms --com
```

#### Литература (Дополнить)



# Шпаргалка git

#### Первым делом

Перед началом работы  с репозиторием нужно минимум задать имя пользователя и почту, [подробнее тут](https://git-scm.com/book/ru/v2/Введение-Первоначальная-настройка-Git). Задается ключиком либо для локально для репозитория --local, либо для текущего пользователя --global, либо для сисемы целиком --system.

```bash
$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com
```

Все эти настройки лежат в файле  .gitconfig (либо в репозитории, либо в домашней папке ~). Еще можно добавить алиасы, они экономят время

```ini
$ cat ~/.gitconfig
[user]
  name = John Doe
email = johndoe@example.com
[color]
  ui = auto
[alias]
  ci = commit
  co = checkout
  st = status
```

Чтобы посмотреть все установленные настройки и узнать где именно они заданы, используйте команду, находясь внутри репозитория:

```bash
$ git config --list --show-origin
```

#### Cоздать репозиторий

```bash
$ git init          - cоздать репозиторий
$ git clone <url>   - cклонировать репозиторий
```

#### История

```bash
$ git log                   - история коммитов
$ git show                  - информация о последнем коммите
$ git show <hash>           - информация об определенном коммите
$ git diff                  - непроиндексипрованный изменения
$ git diff --cached         - проиндексированные изменения

$ git log --all             - коммиты всех веток
$ git log -p                - показывает дельту изменений
$ git log --graph --all     - рисует граф ветвлений
$ git log --oneline	        - выводит коммиты в одну строчку
$ git blame                 - показывает, какие коммиты меняли строки файла
$ git remote -v             - посмотреть информацию об онлайн репозиториях
```

#### Добаить файлы в stage фазу

```bash
$ git add	<name>  - добавить файл в отслеживаемые
$ git add .       - добавить все файлы в отслеживаемые
```

#### Коммит

```bash
$ git commit -am "Comment"  - с ключом -а индексируются все измененный и удаленные файлы. Ключ -m позволяет сразу задать комментаррий
$ git commit --amend        - позволяет изменить последний коммит (предварительно нужно добавить изменения в stage)
```

#### Безопасная отмена изменений определенного коммита

Создается еще один коммит в котором происходит отмена.

```bash
$ git revert <hash>     - отмена определенного коммита (обычно на этом месте возникает кофликт)
$ git status            - посмотреть, где произошел конфликт
$ git show <hash>       - посмотреть, что требуется удалить
# затем нужно вручную удалить лишнее и маркеры
$ git add <name>        - добавить файл в stage
$ git revert --continue - продолжить процесс отмены коммита
```

####  Ветки

```bash
$ git branch                - посмотреть текущее состояние веток
$ git branch <name>         - создать ветку
$ git checkout -b <name>    - создать ветку и перейти внее
$ git merge <name>          - слить ветку <name> с текущей в которой находимся
```

#### .gitignore

Позволяет явно объявить какие имена файлов не нужно отслеживать. Можно использовать маски.

#### .git/hooks

Git позволяет выполнять определённые сценарии, когда происходят важные действия. Сценарии git находятся в каталоге .git/hooks.

Перехватчики могут быть:

- На стороне клиента

  - pre-commit https://pre-commit.com/

    ```bash
    $ pip install pre-commit	-  установит автоматический обработчик
    # затем в папку с проектом нужно добавить конфигурационный файл .pre-commit-config.yaml
    $ pre-commit install
    ```

  - pre-push

  - др.

- На стороне сервера

  - pre-receive
  - post-receive
  - др.

Создание git hooks

- Должны находиться строго в директории .git/hooks
- Момент запуска того или иного скрипта определяется по его имени
- Могут быть написаны с использованием любого скриптового языка. Например: bash, python и др.
- Выполнение git hooks не считается успешным, если он завершается с любым кодом не равным 0

https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks

#### Rebase  (дополнить)

Пока мы не опубликовали наши изменения, можно "переписывать историю" с помощью rebase, например так:

```
$ git rebase -i HEAD~4
```

#### Полезные дополнения

```
 $ git log --grep=XXX позволяет выполнять поиск по сообщениям в коммитах
 $ git log --graph --abbrev-commit --decorate --all --oneline - наглядно показать историю
```

#### Инструменты

https://www.sourcetreeapp.com/

#### Литература

https://learngitbranching.js.org/

http://zzet.org/git/learning/undev/coursify/2014/02/09/lection-1-git-course-undev.html

https://git-scm.com/book/ru/v2
