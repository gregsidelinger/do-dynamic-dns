FROM digitalocean/doctl:1-latest

ENTRYPOINT /app/update-dns.sh

# Make sure doctl is in our PATH
env PATH=$PATH:/app

ADD update-dns.sh /app/update-dns.sh

# Add jq and dig commands
RUN apk add jq bind-tools \
 && chmod a+rx /app/update-dns.sh

