# pull images
#docker pull index.docker.io/sameersbn/postgresql
#docker pull index.docker.io/sameersbn/redis
#docker pull index.docker.io/sameersbn/gitlab
#docker pull index.docker.io/sameersbn/gitlab-ci-multi-runner

# make directory in host
mkdir -p /srv/docker/gitlab/postgresql
mkdir /srv/docker/gitlab/redis
mkdir /srv/docker/gitlab/gitlab
mkdir /srv/docker/gitlab/gitlab-runner

# run
docker run --name gitlab-postgresql -d --env 'DB_NAME=gitlabbhq_production' --env 'DB_USER=gitlab' --env 'DB_PASS=password' --env 'DB_EXTENSION=pg_trgm' --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql sameersbn/postgresql
docker run --name gitlab-redis -d --volume /srv/docker/gitlab/redis:/var/lib/redis sameersbn/redis
#docker run --name gitlab -d --link gitlab-postgresql:postgresql --link gitlab-redis:redisio --publish 10022:22 --publish 10080:80 --env 'GITLAB_HOST=192.168.0.122' --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_SECRETS_DB_KEY_BASE=kazaffisagoodcoder' --env 'GITLAB_SECRETS_SECRET_KEY_BASE=dockeriswonderfull' --env 'GITLAB_SECRETS_OTP_KEY_BASE=somanysecretskeys' --env 'GITLAB_BACKUP_SCHEDULE=daily' --volume /srv/docker/gitlab/gitlab:/home/git/data sameersbn/gitlab
docker run --name gitlab -d --link gitlab-postgresql:postgresql --link gitlab-redis:redisio --publish 10022:22 --publish 10080:80 --env 'GITLAB_HOST=gitlab.baiyjk.com'  --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_SECRETS_DB_KEY_BASE=kazaffisagoodcoder' --env 'GITLAB_SECRETS_SECRET_KEY_BASE=dockeriswonderfull' --env 'GITLAB_SECRETS_OTP_KEY_BASE=somanysecretskeys' --env 'GITLAB_BACKUP_SCHEDULE=daily' --env 'SMTP_ENABLED=true' --env 'SMTP_HOST=smtp.163.com' --env 'SMTP_PORT=25' --env 'SMTP_USER=baiyyy_gitlab@163.com' --env 'SMTP_PASS=baiyyy2012' --env 'SMTP_AUTHENTICATION=login' --dns=192.168.0.5 --volume /srv/docker/gitlab/gitlab:/home/git/data sameersbn/gitlab

#docker run --name gitlab-ci-multi-runner -d --restart=always --volume /srv/docker/gitlab-runner:/home/gitlab_ci_multi_runner/data --link gitlab:gitlab --env='CI_SERVER_URL=http://gitlab/ci' --env='RUNNER_TOKEN=Tm-wsP_Syo52RriUPJAe' --env='RUNNER_DESCRIPTION=baiyyy' --env='RUNNER_EXECUTOR=shell' sameersbn/gitlab-ci-multi-runner
