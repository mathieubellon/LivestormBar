release:
	./bin/generate_appcast releases
	aws s3 sync releases s3://livestormbar --exclude '.DS_store'
