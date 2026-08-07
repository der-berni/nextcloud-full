all: build stop start

build:
	docker build -t ghcr.io/der-berni/nextcloud-full:latest .

stop:
	docker stop nextcloud-full || true

start:
	docker run -it --rm --name nextcloud-full ghcr.io/der-berni/nextcloud-full:latest

clean:
	docker rm nextcloud-full || true
	docker rmi ghcr.io/der-berni/nextcloud-full:latest || true
