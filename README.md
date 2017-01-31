# ActiveRecord `from` Examples

An example project that shows a cool trick everyone should be using...

# TD;RL

Clone and run it!

```bash
git clone https://github.com/vovimayhem/activerecord-from-example.git \
  && cd activerecord-from-example \
  && docker-compose up -d web
```

The service should be ready in a couple of minutes at http://localhost:3000

Then follow the onscreen instructions :)

## Ruby Version

This project currently uses MRI Ruby 2.3.3

## System dependencies

This project is developed using Docker, and you can find exactly which system dependencies are
present used and how they are installed can be found in the [development Dockerfile](./dev.Dockerfile):

  * Debian build tools (which come bundled in the Ruby Docker image)
  * NodeJS (7.3.0) for asset compiling

## Configuration

Being a 12-factor dockerized app, most of the configuration is done via environment variables
defined in the [project's Compose file](./docker-compose.yml) (including `DATABASE_URL` and
`REDIS_URL`), which will be injected into the containers by Docker Compose, and will also interpolate
variables defined in the `.env` dotenv file. An [example dotenv file](./example.env) is available at
the project's root for you to copy and update at will.

## Database creation / initialization

Using Docker Compose, the database initialization is done automatically by the
[development entrypoint script](./development-entrypoint) when running any rails/hutch/sidekiq
process containers for the first time (it won't run if launching bash in a container)

If your'e not using Docker Compose, the normal rails commands still apply.

## Services

* Postgres as the main database
* Rails web service
