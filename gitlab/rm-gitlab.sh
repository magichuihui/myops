docker rm -f gitlab
docker rm -f gitlab-redis
docker rm -f gitlab-postgresql


service docker restart

rm -rf /srv/*
