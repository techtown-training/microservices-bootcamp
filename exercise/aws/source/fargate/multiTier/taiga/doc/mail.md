Configuring SMTP
================

If you want to use an SMTP server for emails, you'll need to specify all of
these additional arguments to your `docker run` command.

- `-e TAIGA_ENABLE_EMAIL=True`
- `-e TAIGA_EMAIL_FROM=no-reply@taiga.mycompany.net`
- `-e TAIGA_EMAIL_USE_TLS=True` (only if you want to use tls)
- `-e TAIGA_EMAIL_HOST=smtp.google.com`
- `-e TAIGA_EMAIL_PORT=587`
- `-e TAIGA_EMAIL_USER=me@gmail.com`
- `-e TAIGA_EMAIL_PASS=super-secure-pass phrase thing!`

**Note:** This can also be configured directly inside your own config file, 
with a specific `taiga-conf/local.py`. You can then configure this
and other [settings available in Taiga](https://github.com/taigaio/taiga-back/blob/master/settings/local.py.example).
