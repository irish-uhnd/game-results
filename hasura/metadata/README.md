# initialization instructions
docker-compose -up -d
# Add database in localhost:8080 console
hasura migrate apply
hasura metadata apply
