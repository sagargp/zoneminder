docker run \
  --name=zoneminder \
  --env="TZ=America/Los_Angeles" \
  --volume="/srv/media/docker_data/zoneminder/zoneminder:/var/cache/zoneminder:rw" \
  --volume="/srv/media/docker_data/zoneminder/mysql:/var/lib/mysql:rw" \
  --volume="/srv/media/docker_data/zoneminder/backups:/var/backups:rw" \
  --volume="/var/cache/zoneminder" \
  --volume="/var/lib/mysql" \
  --volume="/var/backups" \
  -p 1234:80 \
  -p 1236:3306 \
  --restart=no \
  --detach=true \
  --shm-size=4096m \
  sagargp/zoneminder
