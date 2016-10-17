run:
	docker-compose up -d coordinator

scale:
	docker-compose scale member=4

logs:
	docker-compose logs -f

stop:
	docker-compose down
