<!--
# @title README - Decko on Docker
-->

# Decko on Docker

Docker (no relation to Decko) is a set of tools for organizing software into packages
called containers. Decko maintains several Docker images to support installing,
developing, deploying, and maintaining Decko decks.

The biggest advantage of using Docker is that you needn't give a moments thought to installing dependencies (other than Docker itself). The decko app containers already have imagemagick, memcached, passenger, node, and nginx installed and configured and ready to go. And the "Decko Chambers"

To use the following, you will
need [Docker installed](https://docs.docker.com/get-docker/) (and for most use cases you
will also want [Docker compose](https://docs.docker.com/compose/install/)).

## Sandbox

If you just want to give Decko a quick try without worrying about saving your work, you
can install a sandbox with the following command:

`docker run -dp 4444:80 ethn/decko-sandbox`

That will install a fully operational, seeded deck that will be available on a browser on
port 4444 of the host server. For example, if you are running this command on your local
computer, you should be able to see the deck at `http://localhost:4444`.

Note: in the sandbox, all the data is stored inside the docker container; when the
container is gone, so is the data. ***You should NOT keep any valuable data in a sandbox
deck***.

## Decko Chambers

A second set of handy Docker images is intended for folks who want standard decks _and
don't need to write mod code_. If you're not sure whether you need mods this is a good way
to get started with Decko. If you later decide you need mods, it's straightforward to
upgrade.

The most straightforward way to install decko chambers is with decko compose. 

1. Make a directory for your deck and copy [docker-compose.yml](docker-compose.yml) into it.
2. Edit the file and choose:
   - A database engine. Default is MySQL, but you can choose PostgreSQL with a little commenting / uncommenting.
   - File storage (eg for uploaded files and images). Default is to store files on the host. For that to work, you'll only need to make a directory named `files` in your deck directory. See comments if you'd prefer cloud storage. 
3. Run the following:
   - `docker compose up -d` # this creates your volumes, starts your containers, etc.
   - `docker compose exec app decko setup` # this creates and seeds your decko database

As with the sandbox this will by default make a site available on port 4444, though that too can be configured in the docker-compose.yml file. 

Docker gives you a lot of power to manipulate the containers, and you can consult their excellent documentation to learn more.  (We highly recommend the docker tutorial.) But here are a few crucial commands:

- `docker compose down` # shut down the containers
- `docker compose exec app bash` # open a bash shell to the app container 
- `docker compose exec db bash` # open a bash shell to the database container

### Upgrading

To update an existing docker site to use a more recent decko docker image:

1. `docker compose pull app`
2. `docker compose down`
3. `docker compose up -d`
4. `docker compose exec app decko update`

For some upgrades, it may be necessary to repeat steps two and three to restart things 
after running the update.

## For Monkeys

Increased support for monkeys who want to use Docker when developing is coming soon.  The idea is to create options for `decko new` that will create the basic structure (Dockerfile, etc) to use docker containers in all stages of site creation.

In the meantime, you can get a sense of how that would look by looking at how the Dockerfile is structured in the docker directory in the decko repo. 
