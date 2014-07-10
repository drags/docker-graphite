# docker-graphite

Personal spin of graphite in docker.

	- Ubuntu trusty
	- graphite 0.9.x
	- nginx + uwsgi
	- supervisor

Create a new branch to customize your install before building. Be sure to at least change SECRET_KEY in `conf/docker-web/local_settings.py`.

## Ports and Volumes

This container **requires** a few connected ports and a data volume for **at least** the whisper data.

### Ports exposed by the container:

    - 80: graphite-web
    - 2003: carbon cache

### Data volumes

Since docker containers are ephemeral and don't persist any writes to disk it is necessary to store the Whisper data on the docker host. One caveat to docker volumes is that while the extended UID space is "re-aligned" (so that docker UID 1234 == host UID 1234 for permissions purposes) there is no reason for docker host and docker container users to be assigned the same UID. There are a couple of ways to solve this:

    - Currently within the container the graphite user is UID 2001, and the graphite group is GID 2001. These UIDs are likely to be unclaimed on the docker host, so you can create a graphite-specific user and assign it these IDs.
    - Alternatively you can modify the groupadd and useradd calls in the Dockerfile to provide your own statically assigned IDs.

In order for metric data to persist from one container to the next, at least the `/opt/graphite/storage/whisper` directory of the container needs to be a [docker volume](https://docs.docker.com/userguide/dockervolumes/).

Here's an example `docker run` command with the ports exposed to the outside world and `/data/graphite` from the host mounted at `/opt/graphite/storage/whisper`. It's up to the user to ensure that /data/graphite exists and is writable by the graphite user from the docker container:

    `docker run -d -p 8080:8080 -p 2003:2003 -v /data/graphite:/opt/graphite/storage/whisper/ graphite`
