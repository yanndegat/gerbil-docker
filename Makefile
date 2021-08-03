gambit:
	docker build -t yanndegat/gambit:latest -f Dockerfile.gambit .

gerbil: gambit
	docker build -t yanndegat/gerbil:latest -f Dockerfile .
