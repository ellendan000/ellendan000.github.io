docker build -t gitbook-local .
docker run -ti -v $(pwd):/app -p 4400:4000 gitbook-local