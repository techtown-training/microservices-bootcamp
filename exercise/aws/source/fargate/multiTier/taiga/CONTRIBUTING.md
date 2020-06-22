CONTRIBUTING
============

Where to start
--------------

If you clone the repository don't forget to get submodules recursively.

```bash
git clone https://github.com/ajira86/docker-taiga.git --recursive
```

Else, you can get them later with the following command.

```bash
git submodule update --init --remote
```

If you want to run a simple local server, you can use docker-compose.

```bash
docker-compose up
```

Dockerhub organization
----------------------

The builds are automated on Dockerhub with the following rules:

 * Push on master and alpine branch will regenerate nightly and nightly-alpine images.
 * Pushed tags will trigger build for same tag, latest and latest-alpine images.

A temporary travis image exists to prepare tested process befaore manual build and push:

 * Push on travis branch push trigger .travis.yml instructions [Travis linked service](https://travis-ci.com/ajira86/docker-taiga).
