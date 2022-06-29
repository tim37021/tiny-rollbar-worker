Tiny Rollbar Worker
===
## Usage
```bash
./scripts/start_worker.sh
```

## Build
```bash
docker build -t tiny-rollbar-worker < Dockerfiles/Dockerfile-alpine
```
or you can specify base image with `--build-args`, I would recommend to use offical ruby image
```bash
docker build -t tiny-rollbar-worker --build-args BASE_RUBY_IMAGE=ruby:3.0.0 < Dockerfiles/Dockerfile-alpine
```

## Environment Variables
- `ROLLBAR_ACCESS_TOKEN=`
- `WORKER_CONCURRENY=1`
- `WORKER_QUEUE=rollbar`
- `REDIS_HOST=127.0.0.1`
- `REDIS_PORT=6379`
- `REDIS_DB=0`
- `REDIS_ENABLE_SSL=0`

## Stats
With default settings, the container roughly takes 30MB memory. Image size=101MB

## TODOs
- [ ] Reduce image size
