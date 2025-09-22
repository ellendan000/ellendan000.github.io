docker build -t gitbook-local .
docker run -d -v $(pwd):/app -p 4400:4000 gitbook-local