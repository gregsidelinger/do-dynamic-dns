# do-dynamic-dns
A simple shell script to update a Digital Ocean managed DNS record with your
internet IP. 

It is designed to be ran from a kubernetes cronjob every few min.


If the record already exists only the IP address will be updated using the doctl.
If new A record needs to be created it will have a TTL of 180 by default.


# Setup

## Pre Work
Create a Digial Ocean API token from their site.

Place it into a kubernetes secret called do digitalocean under a key called token.
Below is an exmaple kubernetes yaml file for the secret.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: digitalocean
type: Opaque
stringData:
  token: YOUR_DO_API_TOKEN
```
NOTE: stringData is being used so you do not need to base64 encode anything.

## Cronjob
Update the example cronjob.yaml with your DNS Domain name and your DNS record.
If you wanted dyanmic.example.com to contain an A record with your public IP 
address you would use example.com as the DOMAIN and dyanmic as the RECORD.
You have to have the domain setup to managed via Digital Oceans DNS tools.

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name:  do-dns-update
spec:
  schedule: "*/5 * * * *" # Run every 5 min
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: gregsidelinger/do-dynamic-dns
            imagePullPolicy: Always
            env:
            - name: DOMAIN
              value: example.com
            - name: RECORD
              value: dynamic
            - name: DIGITALOCEAN_ACCESS_TOKEN
              valueFrom:
                secretKeyRef:
                  name: digitalocean
                  key: token
          restartPolicy: Never
```

