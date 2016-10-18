run:
	docker-compose up -d

status:
	docker-compose exec coordinator riak-admin cluster status

logs:
	docker-compose logs -f

stop:
	docker-compose down

clean:
	docker volume rm `docker volume ls -q -f dangling=true`

init:
	docker-compose exec coordinator riak-admin bucket-type create maps '{"props":{"datatype":"map"}}'
	docker-compose exec coordinator riak-admin bucket-type activate maps
	docker-compose exec coordinator riak-admin bucket-type create sets '{"props":{"datatype":"set"}}'
	docker-compose exec coordinator riak-admin bucket-type activate sets
	docker-compose exec coordinator riak-admin bucket-type create counters '{"props":{"datatype":"counter"}}'
	docker-compose exec coordinator riak-admin bucket-type activate counters
