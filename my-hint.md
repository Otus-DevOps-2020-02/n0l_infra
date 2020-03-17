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
