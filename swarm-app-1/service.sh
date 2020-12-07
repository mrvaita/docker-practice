# create front and backend networks
docker network create --driver overlay voting_backend
docker network create --driver overlay voting_frontend

# create voting frontend service
docker service create \
    --name voting \
    --network voting_frontend \
    --replicas 2 \
    --detach true \
    -p 80:80 \
    bretfisher/examplevotingapp_vote

# create redis service
docker service create \
    --name redis \
    --network voting_frontend \
    --detach true \
    redis:3.2

# create working service
docker service create \
    --name worker \
    --network voting_frontend \
    --network voting_backend \
    --detach true \
    bretfisher/examplevotingapp_worker:java

# create postgres service
docker service create \
    --name psql \
    --network voting_backend \
    --detach true \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    --mount type=volume,source=db-data,target=/var/lib/postgresql/data \
    postgres:9.4

# create voting_result service
docker service create \
    --name voting_result \
    --network voting_backend \
    --detach true \
    -p 5001:80 \
    bretfisher/examplevotingapp_result
