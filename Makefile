# TODO: DRY up using Makefile functions

# development and test container commands
start-all: dev-start test-start

stop-all: dev-stop test-stop


# development container commands
dev-start:
	docker-compose -p riakdev up -d

dev-status:
	docker-compose -p riakdev exec coordinator riak-admin cluster status

dev-logs:
	docker-compose -p riakdev logs -f

dev-stop:
	docker-compose -p riakdev down

dev-init:
	docker-compose -p riakdev exec coordinator riak-admin bucket-type create maps '{"props":{"datatype":"map"}}'
	docker-compose -p riakdev exec coordinator riak-admin bucket-type activate maps
	docker-compose -p riakdev exec coordinator riak-admin bucket-type create sets '{"props":{"datatype":"set"}}'
	docker-compose -p riakdev exec coordinator riak-admin bucket-type activate sets
	docker-compose -p riakdev exec coordinator riak-admin bucket-type create counters '{"props":{"datatype":"counter"}}'
	docker-compose -p riakdev exec coordinator riak-admin bucket-type activate counters


# test container commands
test-start:
	docker-compose -f docker-compose.yml -f docker-compose.test.yml -p riaktest up -d 

test-status:
	docker-compose -p riaktest exec coordinator riak-admin cluster status

test-logs:
	docker-compose -p riaktest logs -f

test-stop:
	docker-compose -p riaktest down

test-init:
	docker-compose -p riaktest exec coordinator riak-admin bucket-type create maps '{"props":{"datatype":"map"}}'
	docker-compose -p riaktest exec coordinator riak-admin bucket-type activate maps
	docker-compose -p riaktest exec coordinator riak-admin bucket-type create sets '{"props":{"datatype":"set"}}'
	docker-compose -p riaktest exec coordinator riak-admin bucket-type activate sets
	docker-compose -p riaktest exec coordinator riak-admin bucket-type create counters '{"props":{"datatype":"counter"}}'
	docker-compose -p riaktest exec coordinator riak-admin bucket-type activate counters

# docker helpers commands
clean:
	docker volume rm `docker volume ls -q -f dangling=true`
