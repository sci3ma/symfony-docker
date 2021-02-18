# Symfony Docker

Complete Docker stack for Symfony with NGINX, PHP, MySQL and MinIO, using docker-compose tool.
```
+-----------+-----------+----------+----------+----------+
|           |           |          |          |          |
|   NGINX   |  PHP-FPM  |   MySQL  |   MinIO  |  MailHog |
|           |           |          |          |          |
+-----------+-----------+----------+---------------------+
|                                                        |
|                      Docker Engine                     |
|                                                        |
+--------------------------------------------------------+
|                                                        |
|                         Host OS                        |
|                                                        |
+--------------------------------------------------------+
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
Optionally PHP for [docker/composer](docker/composer), [docker/console](docker/console) and [docker/git](docker/git) scripts. 


## Features
- [NGINX](https://www.nginx.com/) - web server
- [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) - PHP FastCGI Proces Manager
- [Xdebug](https://xdebug.org/) - PHP extension for debugging
- [MySQL](https://www.mysql.com/) - relational database
- [MinIO](https://min.io/) - AWS S3 (or Google Cloud, Microsoft Azure) object storage
- [MailHog](https://github.com/mailhog/MailHog) - web and API based SMTP testing tool
- [Elasticsearch](https://www.elastic.co/elasticsearch/) - search and analytics engine (not yet implemented)


## Configuration

### Configuration reference
Before you run docker, put configuration environment variables to `.env` file located in root folder of your project and set desired version numbers of all services.
```dotenv
MYSQL_VERSION=8.0                   # MySQL version
PHP_VERSION=8.0                     # PHP version (make sure is supported by Xdebug version https://xdebug.org/docs/compat)
APCU_VERSION=5.1.19                 # APCU version
PHP_CONTAINER_NAME=php              # PHP-FPM container name
NGINX_CONTAINER_NAME=nginx          # NGINX container name
DATABASE_CONTAINER_NAME=database    # Database container name
S3_CONTAINER_NAME=minio             # MinIO container name
S3_KEY=s3_key                       # MinIO key/login
S3_SECRET=s3_secret                 # MinIO secret/password
MAILHOG_CONTAINER_NAME=mailhog      # MailHog container name
XDEBUG_VERSION=3.0.2                # Xdebug version (make sure is supported by PHP version https://xdebug.org/docs/compat)
XDEBUG_HOST=0.0.0.0                 # IP address of your host
```

### Ports
- NGINX works on port `8000`, `http://127.0.0.1:8000`
- MySQL works on port `3306` inside docker network and on port `33060` outside docker network.
- MinIO works on port `8001`, `http://127.0.0.1:8001`
- MailHog web works on port `8025`, `http://127.0.0.1:8025`. SMTP works on port `1025`, `smtp://127.0.0.1:1025`
- Xdebug works on port `9001`, idekey is `PHPSTORM`
```
  Name                Command               State                       Ports                     
--------------------------------------------------------------------------------------------------
database   docker-entrypoint.sh --def ...   Up      0.0.0.0:33060->3306/tcp, 33060/tcp            
mailhog    MailHog                          Up      0.0.0.0:1025->1025/tcp, 0.0.0.0:8025->8025/tcp
minio      /usr/bin/docker-entrypoint ...   Up      0.0.0.0:8001->9000/tcp                        
nginx      /docker-entrypoint.sh ngin ...   Up      0.0.0.0:443->443/tcp, 0.0.0.0:8000->80/tcp    
php        docker-php-entrypoint php-fpm    Up      9000/tcp
```

## Installation
To install `Symfony Docker`, clone this repository, then build containers:
```bash
$ docker-compose build
```
and run:
```bash
$ docker-compose up -d
```
When containers are up and running create bucket and add policy using MinIO web interface: `http://127.0.0.1:8001`. To log in use S3_KEY and S3_SECRET values.

Put your Symfony project next to Symfony Docker.
To setup database connection in Symfony just add in `.env` file:
```dotenv
DATABASE_URL=mysql://dbuser:password@database:3306/symfony?serverVersion={MYSQL_VERSION}
```
If you want to connect to MySQL from outside e.g. in PHPSTROM or any other SQL Client use credentials:
```
MYSQL_DATABASE: symfony
MYSQL_USER: dbuser
MYSQL_PASSWORD: password
MYSQL_HOST: [container_name]
MYSQL_PORT: 33060
```


## Usage

### Start
To start docker containers in the background run with `-d` option:
```bash
$ docker-compose up -d
```

### Stop
Stop docker containers and remove docker network run:
```bash
$ docker-compose down
```

### Get into container
Usually you don't need to do anything inside container except in the php one. To get into any container run:
```bash
$ docker exec -it [container_name] sh
```


### Docker scripts
There are 3 scripts in `docker/` folder which can help you speed up executing daily commands like `git commit`, `composer update` or `bin/console clear:cache` without logging into container.
To use them you have to install PHP 7.0 or newer and Symfony Dotenv Component on your local machine.
```
docker/git [command]       # similar to: git [command]
docker/composer [command]  # similar to: composer [command]
docker/console [command]   # similar to: bin/console [command]
```


### To do
- implement container with Elasticsearch
- implement container with message queuing service (RabbitMQ/AWS SQS)
- improve Xdebug configuration to setup client host IP address automatically
