# docker-postgres-debian74
==================

Dockerfile to build an image of Postgres 9.4.1 over a Debian 7.4. The goal is
to build an image that is similar to the one provided by Cloud At Cost, allowing
us to test and develop with basically the same architecture of the production
environment. The base script was extracted from:
https://github.com/docker-library/postgres/tree/master/9.4

Getting started
---------------

I recommend that you configure your current user to manipulate docker without sudo.
Check [this](http://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo) out to learn how.

1. Build the new image (from the same directory of this Dockerfile):
```
$ docker build -t djlebersilvestre/postgres:9.4.1 .
$ docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
djlebersilvestre/postgres   9.4.1               7c4d4f1185ec        4 seconds ago       278.5 MB

```
Or you can build directly from git:
```
$ docker build -t djlebersilvestre/postgres:9.4.1 https://github.com/djlebersilvestre/docker-postgres-debian74.git
```

2. Start the server:
```
$ docker run --name postgres -d -p 127.0.0.1:5432:5432 djlebersilvestre/postgres:9.4.1
```

3. Access the server with the client already installed in the image:
```
$ docker run --rm -it --link postgres:postgres djlebersilvestre/postgres:9.4.1 sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```
Or you can setup your application / client to `host=127.0.0.1`,  `port=5432` and `password=<in Dockerfile, but probably is 'testing'>`

### To run the image and poke around its file system
```
$ docker run --rm -it djlebersilvestre/postgres:9.4.1 /bin/bash
```

### To build a new Dockerfile upon this image (use the public image \o/)
```
FROM djlebersilvestre/postgres:9.4.1
# customize your image
```
