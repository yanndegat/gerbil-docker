all: gerbil

gambit:
	docker build --network=host -t yanndegat/gambit:latest -f Dockerfile.gambit .

gerbil: gambit
	docker build --network=host -t yanndegat/gerbil:latest -f Dockerfile .
