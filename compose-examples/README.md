### Compose files example for deploy cups.

- For `traefik_labels_env.yaml` you will need  a .env (environment) file in the same directory with the following:

```shell
# .env file
 CUPS_ADMIN_USER=your-username
 CUPS_ADMIN_PASSWORD=your-password
 AVAHI_HOSTNAME=cups-server
 TRAEFIK_SERVICE_NAME=cups
 TRAEFIK_SERVICE_PORT=631
 DOMAIN_NAME=`https://your-domain.com`
 ```

> Note: You will still needing to expose the CUPS (631) port, I haven't found a way to use the reverse proxy for make all the jobs throught there.
