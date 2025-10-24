FROM alpine:latest

ENV TZ=UTC \
    AVAHI_HOSTNAME=cups-server \
    CUPS_ADMIN_USER=admin \
    CUPS_ADMIN_PASSWORD=password

# Install dependencies and CUPS
RUN apk update && apk upgrade
RUN apk add --no-cache \
    tzdata \
    cups \
    cups-filters \
    cups-libs \
    cups-client \
    epson-inkjet-printer-escpr \
    usbutils \
    dbus \
    avahi \
    inotify-tools \
    bash \
    avahi-tools
RUN apk cache clean

# Copy configuration and scripts
RUN sed -i 's/Listen localhost:631/Listen *:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "BrowseProtocols dnssd" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf && \
    sed -i 's|^ErrorLog .*|ErrorLog stderr|' /etc/cups/cups-files.conf && \
    sed -i 's|^AccessLog .*|AccessLog stderr|' /etc/cups/cups-files.conf && \
    sed -i 's|^PageLog .*|PageLog stderr|' /etc/cups/cups-files.conf

COPY entrypoint.sh /entrypoint.sh

# Create directories and permissions
RUN mkdir -p /var/run/dbus \
    && chown root:lp /etc/cups \
    && chmod 775 /etc/cups \
    && chmod +x /entrypoint.sh

# Backup cups configs in case used does not add their own
RUN cp -rp /etc/cups /etc/cups-bak

EXPOSE 631
EXPOSE 5353/udp

VOLUME [ "/etc/cups" ]
VOLUME [ "/var/spool/cups" ]
ENTRYPOINT ["/entrypoint.sh"]
