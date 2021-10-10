# WAT

Run a docker-registry pull through cache (in production) so you can

- cache docker pulled docker images in your companies network to reduce the extern traffic load
- e.g. reduce amount of request done to the official `hub.dockerg.com` registry (and avoid rate limit issues)
- use a shared credentials to access a private registry, without involving authentication on the client side

You can use it for some or all, as you like.

This concept is called pull-through cache, see official docs;

- https://docs.docker.com/registry/recipes/mirror/
- https://circleci.com/docs/2.0/docker-hub-pull-through-mirror/

## WAT is the difference

Most of the pull through registries are i found (like [this](https://github.com/rpardini/docker-registry-proxy)) offer some what of a custom image, including a custom nginx.
They also give you not fast upstart.

This is the main difference, we use the official `registry` image and we use an standalone ssl-offloader `traefik` which
also gives us the ability to use `ACME` or what ever you pick from (or use no off-loader at all - or your own).
Also, you can just add more registries and thus add several caches, if you need those - all with one ssl-offloader.

Use this repository to run it in production or test, use it as an fast upstart and use it as building blocks.

# WAT it's not

It should not used as a docker-registry boilerplate, this one is designed to be a pull-through cache, not a private
docker registry:

# Usage (test)

First create the `.env` file using `cp env.local.example .env` and adjust the values

- `USERNAME1` and `PASSWORD1` for upstream authentication
- `CACHE_DOMAIN1` for your domain you want to access the pull-through cache with

If you want, set the custom `UPSTREAM_REGISTRY1` to use your `private registry` as upstream.

```bash
docker-compose up -d
# or

./start.sh
```

That's about it.

## Updating

Pulls the newest images of `registry` and `traefik` and if needed, apply those.

```
./update.sh
```

## SSL (production)

The easiest mode to enable `SSL` is simply replacing the first line in you `.env` with

`COMPOSE_FILE=docker-compose.yml:docker-compose-traefik-http.yml`

So we switch from `traefik` non ssl (testing) to `httpd` challenge based SSL via ACME.

```bash
docker-compose up -d
```

## SSL advanced

If you want to use `DNS` based challenges for `ACME`, e.g. since you are in a private network, change `.env` to

`COMPOSE_FILE=docker-compose.yml:docker-compose-traefik-dns.yml`

And add the following variables to your `.env`

```env
TRAEFIK_ACME_CHALLENGE_DNS_PROVIDER=cloudflare
TRAEFIK_ACME_CHALLENGE_DNS_CREDENTIALS=CF_DNS_API_TOKEN=<YOURTOKEN>
```

Be sure to replace `<YOURTOKEN> with your cloudflare API token.

Chose a difference provider and adjust the credentials if you like/need. of course.
The providers you can pick from can be found in the [traefik docs](https://doc.traefik.io/traefik/https/acme/#providers).
Be sure to adjust the `CF_DNS_API_TOKEN` key to whatever your provider needs.

## Advanced (more registries)

If you want to host more registries, since each registry-cache can only have one upstream, you can easily do so.
See the `docker-compose-registry2.yml` and add it to your `.env` file

`COMPOSE_FILE=docker-compose.yml:docker-compose-traefik-http.yml::docker-compose-registry2.yml`

Be suer to set `USERNAME2`/`PASSWORD2`/`CACHE_DOMAIN2`/`UPSTREAM_REGISTRY2` (be sure to notice the `2` .. second registry)
in the `.env` file.

That's it, your traefik will take care of all the rest.

If you like, copy `docker-compose-registry2.yml` to `docker-compose-registry3.yml` .. change the ENV vars, set them
and you have the third. Repeat as often as you like
