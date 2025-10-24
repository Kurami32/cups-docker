#!/bin/bash

dbus-uuidgen --ensure
dbus-daemon --system --nofork &

# Sync time with the specified timezone
if [ -n "$TZ" ]; then
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
    echo "Timezone set to: $TZ"
fi

# Start Avahi with hostname from env variables (or default if don't specify any)
hostname=${AVAHI_HOSTNAME:-cups-server}
sed -i "s/host-name=.*/host-name=${hostname}/" /etc/avahi/avahi-daemon.conf
avahi-daemon -D
echo "Avahi-daemon started"

# Create CUPS admin user
if [ -n "$CUPS_ADMIN_USER" ] && [ -n "$CUPS_ADMIN_PASSWORD" ]; then
    if ! id "$CUPS_ADMIN_USER" &>/dev/null; then
        adduser -S -G lpadmin --no-create-home $CUPS_ADMIN_USER
    fi
    echo "$CUPS_ADMIN_USER:$CUPS_ADMIN_PASSWORD" | chpasswd
    echo "Created CUPS admin user: $CUPS_ADMIN_USER"
fi

# Set permissions
chown -R root:lp /etc/cups

# Create spool directory
mkdir -p /var/spool/cups/tmp
chown -R root:lp /var/spool/cups

# Add EPSON driver symlinks
mkdir -p /usr/share/cups/model/epson
ln -sf /usr/share/cups/model/epson-escpr/* /usr/share/cups/model/epson/

# Restore default cups config in case user does not have any
if [ ! -f /etc/cups/cupsd.conf ]; then
    cp -rpn /etc/cups-bak/* /etc/cups/
fi

# Monitor USB events and restart CUPS when printers change
(inotifywait -m -e create,delete /dev/bus/usb |
while read -r event; do
    echo "USB change detected. Restarting CUPS..."
    sleep 2
    pkill cupsd
done) &

# Start CUPS
exec cupsd -f
