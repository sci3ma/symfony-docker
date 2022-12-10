# Symfony Docker

Complete Docker stack for Symfony with NGINX, PHP, MySQL, MinIO, MailHog, Redis, RabbitMQ and Elasticsearch using docker-compose tool.
```
+---------+-----------+---------+---------+-----------+---------+----------+-----------------+ 
|         |           |         |         |           |         |          |                 |
|  NGINX  |  PHP-FPM  |  MySQL  |  MinIO  |  MailHog  |  Redis  | RabbitMQ |  Elasticsearch  |
|         |           |         |         |           |         |          |                 |
+---------+-----------+---------+---------+-----------+---------+----------+-----------------+ 
|                                                                                            |
|                                        Docker Engine                                       |
|                                                                                            |
+--------------------------------------------------------------------------------------------+
|                                                                                            |
|                                           Host OS                                          |
|                                                                                            |
+--------------------------------------------------------------------------------------------+
```

## Table of Contents
1. [Requirements](#requirements)
1. [Features](#features)
1. [Configuration](#configuration)
   1. [Configuration reference](#configuration-reference)
   1. [Ports](#ports)
1. [Installation](#installation)
1. [Usage](#usage)
   1. [Start](#start)
   1. [Stop](#stop)
   1. [Get into container](#get-into-container)
   1. [Docker scripts](#docker-scripts)
1. [To do](#to-do) 


## Requirements
Docker Engine 19.03.0 or newer. 

## Features
- [NGINX](https://www.nginx.com/) - web server
- [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) - PHP FastCGI Proces Manager
- [Xdebug](https://xdebug.org/) - PHP extension for debugging and coverage
- [MySQL](https://www.mysql.com/) - relational database
- [MinIO](https://min.io/) - AWS S3 (or Google Cloud, Microsoft Azure) object storage
- [MailHog](https://github.com/mailhog/MailHog) - web and API based SMTP testing tool
- [Redis](https://redis.com/) - in-memory data structure storage
- [RabbitMQ](https://www.rabbitmq.com/) - open source message broker
- [Elasticsearch](https://www.elastic.co/elasticsearch/) - search and analytics engine


## Configuration

### Configuration reference
You can create `.env` file located in root folder and override default values.
```dotenv
PHP_CONTAINER_NAME=php                      # PHP-FPM container name
NGINX_CONTAINER_NAME=nginx                  # NGINX container name
DATABASE_CONTAINER_NAME=database            # Database container name
S3_CONTAINER_NAME=minio                     # MinIO container name
STORAGE_LOGIN=storage_login                 # MinIO key/login
STORAGE_PASSWORD=storage_password           # MinIO secret/password
MAILHOG_CONTAINER_NAME=mailhog              # MailHog container name
DOCKER_HOST_UID=1000                        # Your system user ID (UID)
DOCKER_HOST_GID=1000                        # Your system group ID (GID)
RABBIT_MQ_CONTAINER_NAME=rabbit_mq          # RabbitMQ container name
ELASTICSEARCH_CONTAINER_NAME=elasticsearch  # Elasticsearch container name
```
Check your user ID:
```bash
$ id -u
# or
$ id -u <username>
```
Check your group ID:
```bash
$ id -g
# or
$ id -g <username>
```

### Ports
- NGINX works on port `8000`, `http://127.0.0.1:8000`
- MySQL works on port `3306` inside docker network, and on port `13306` outside docker network.
- MinIO API works on port `9000`, console is acccesible on `http://127.0.0.1:9090`
- MailHog web works on port `8025`, `http://127.0.0.1:8025`. SMTP works on port `1025`, `smtp://[mailhog_container_name]:1025`
- Redis works on port `6379` inside docker network, and on port `16379` outside docker network.
- RabbitMQ works on port `5672`, and RabbitMQ GUI work on port `15672` with `guest` login and password.
- Elasticsearch works on port `9200` and requires default credentials, login: `elastic` and password: `password`.
- Xdebug works on port `9001`, idkey is `PHPSTORM`
```
    Name                   Command               State                                                                           Ports                                                                         
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
database        docker-entrypoint.sh --def ...   Up      0.0.0.0:13306->3306/tcp,:::13306->3306/tcp, 33060/tcp                                                                                                 
elasticsearch   /bin/tini -- /usr/local/bi ...   Up      0.0.0.0:9200->9200/tcp,:::9200->9200/tcp, 9300/tcp                                                                                                    
mailhog         MailHog                          Up      0.0.0.0:1025->1025/tcp,:::1025->1025/tcp, 0.0.0.0:8025->8025/tcp,:::8025->8025/tcp                                                                    
minio           /usr/bin/docker-entrypoint ...   Up      0.0.0.0:9000->9000/tcp,:::9000->9000/tcp, 0.0.0.0:9090->9090/tcp,:::9090->9090/tcp                                                                    
nginx           /docker-entrypoint.sh ngin ...   Up      0.0.0.0:1443->443/tcp,:::1443->443/tcp, 0.0.0.0:8000->80/tcp,:::8000->80/tcp                                                                          
php             docker-php-entrypoint php-fpm    Up      9000/tcp                                                                                                                                              
rabbit_mq       docker-entrypoint.sh rabbi ...   Up      15671/tcp, 0.0.0.0:15672->15672/tcp,:::15672->15672/tcp, 15691/tcp, 15692/tcp, 25672/tcp, 4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp,:::5672->5672/tcp
redis           docker-entrypoint.sh redis ...   Up      0.0.0.0:16379->6379/tcp,:::16379->6379/tcp
```

## Installation
To install `Symfony Docker`, clone this repository, then build containers:
```bash
$ make build
```
and run:
```bash
$ make up
```
When containers are up and running create bucket and add policy using MinIO web interface: `http://127.0.0.1:9090`. To log in use `STORAGE_LOGIN` and `STORAGE_PASSWORD` values.

Put your Symfony project into `/app` folder.
To set up database connection in Symfony just add in `.env` file:
```dotenv
DATABASE_URL=mysql://dbuser:password@database:3306/symfony?serverVersion=8.0
```
If you want to connect to MySQL from outside e.g. in PHPSTROM or any other SQL Client use credentials:
```
MYSQL_DATABASE: symfony
MYSQL_USER: dbuser
MYSQL_PASSWORD: password
MYSQL_HOST: ${DATABASE_CONTAINER_NAME:-database}
MYSQL_PORT: 13306
```


## Usage
Type `make help` to check Makefile commands.

### Start
To start docker containers in the background:
```bash
$ make up
```

### Stop
Stop docker containers and remove docker network run:
```bash
$ make down
```

### Get into container
Usually you don't need to do anything inside container except in the php one. To get into any container run:
```bash
$ make sh
```


### To do
- improve documentation
