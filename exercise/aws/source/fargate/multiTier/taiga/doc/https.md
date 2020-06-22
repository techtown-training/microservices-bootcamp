Enabling HTTPS
==============

Prerequisites
-------------

You will need certificates files. If you need to auto-generate a pair, here is a little example

```
openssl req -new -key ssl.key.bak -out ssl.csr
openssl rsa -in ssl.key.bak -out ssl.key
openssl x509 -req -days 365 -in ssl.csr -signkey ssl.key -out ssl.crt
```

Setup
-----

If you want to enable support for HTTPS, you'll need to specify all of these
additional arguments to your `docker run` command.

  - `-e TAIGA_SSL=True`
  - `-v $(pwd)/ssl.crt:/etc/nginx/ssl/ssl.crt:ro`
  - `-v $(pwd)/ssl.key:/etc/nginx/ssl/ssl.key:ro`

Or create a folder called `ssl`, place your `ssl.crt` and `ssl.key` inside
this directory and then mount it with:

  - `-e TAIGA_SSL=True`
  - `-v $(pwd)/ssl/:/etc/nginx/ssl/:ro`

HTTPS behind reverse proxies
----------------------------

If you have a reveser proxy that is already handling https set `TAIGA_SSL_BY_REVERSE_PROXY`:

- `-e TAIGA_SSL_BY_REVERSE_PROXY=True`

The value of `TAIGA_SSL` will then be ignored and taiga will not handle https,
it will however set all links to https.