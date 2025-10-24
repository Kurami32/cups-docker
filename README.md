# CUPS in docker for Epson Printers

For use this image you can clone the repo or just recreate the same files. You will only need `entrypoint.sh`, `Dockerfile` and `docker-compose.yaml` as well.

## Steps to use this image

1. Clone the repo (or recreate the mentioned files)
2. Once you have all the required files, do:

```shell
docker compose up -d --build
```

Now the cups service should be running, verify the logs:

```shell
docker logs cups
```

You will notice that two directories were created:
- The first (`etc-cups`) is for the cups configs and related files.
- The second (`cups-spool`) is for save the spool (or the "jobs") that you send to the server, so they don't get lose when you rebuild the image or restart the container.

### Verify the printer connection
First of all, make sure that you have your printer physically connected to your server via USB, verify if is recognized by the host with:

```shell
lsusb
```

### Connect the printer to CUPS
Go to the CUPS GUI page in your browser, the URL could be: `http:localhost:631`, or `https://your-server-ip:631` if you are on a remote machine - or `https://your-domain.com` if you are behind a proxy.

1. Once in CUPS GUI, go to `admistration` and enter the **username** and **password** that you used in the docker compose file.
2. Click on `"Add printer"`, you should see you printer there, select it.
3. In the next screen you will have three fields, you can fill them with whatever you want, but I recommend to use your printer name in the "Name" field, usually the first two field are auto-filled - and **MAKE SURE** to activate the "Sharing" (share this printer) option, if not you don't will be able to use the printer from other devices.
4. Then, you will have to choose the driver for the printer, in this case we are using EPSON, so, select that option, search for your printer model, and click `"Add Printer"`.
5. Choose the type of paper, and you preferred options.

### Connect clients
Is basically the same as the setup, but:

- When cliking in `"Add printer"`, if you are not using avahi, or you have problems with auto-discovery, you will need to add the printer manually - Select the option that says: `Internet Printing Protocol (ipp)`
and enter your URI in the `connection` field.

Example URIs: (Replace with your printer name - The same that you utilized in the setup on step 3)

```
ipp://<Your-server-ip>:631/printers/EPSON_L4260_Series
http://<Your-server-ip>:631/printers/EPSON_L4260_Series
https://<Domain_name>/printers/EPSON_L4260_Series
```

- In the step 4, when selecting drivers, make sure to select "IPP Everywhere".

Repeat all on every client.
