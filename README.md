# Grafana, Telegraf and InfluxDB 2.xx System monitoring

## 1. Description and Logic

**Why was this created?**
This stack was created in wish to faster deploy Grafana, Telegraf and InfluxDB on a system and expose it on the internet.

**Brief set up process:**

1. Edit and fill up necessary variables,
2. Run script, which does some work for you,
3. Create InfluxDB creditentials,
4. Edit docker-compose.yaml file with InfluxDB creditentials,
5. Start making dashboard in Grafana!

**Logic behind:**
Telegraf gets system data (docker, net...) and sends it to InfluxDB.
Grafana fetchs data from InfluxDB and displays it.
Because we will expose also InfluxDB on internet we can also send data from servers outside our network.

## 2. Installation

**2.1 Clone repository:**
`git clone https://github.com/KomelT/boilerplates.git`

**2.2 Change directory:**
`cd boilerplates/docker/grafana-monitoring`

**2.3 Edit Nginx data:**
At the end services Grafana and InfluxDB will be exposed to internet.

Duplicate file:
`cp nginx.sample.conf nginx.conf`

Open Nginx configration:
`nano nginx.conf`

Replace Grafana domain:
Remove `grafana.domain.local` and write in your own domain.

```
...
server {
  listen 80;
  root /usr/share/nginx/html;
  index index.html index.htm;
  server_name grafana.domain.local;
...
```

Replace InfluxDB domain:
Remove `influxdb.domain.local` and write in your own domain.

```
...
server {
  listen 80;
  server_name influxdb.domain.local;
...
```

**2.4 Edit docker data:**
Duplucate docker-cpompose file:
`cp docker-compose.sample.yaml docker-compose.yaml`

Edit docker-compose file:
`nano docker-compose.yaml`

Grafana ENV:

- 'HOSTNAME' sets up hostname of Grafana container,
- 'GRAFANA_PUBLIC_URL' you tell your Grafana on what public url it will be exposed,
- 'GRAFANA*SMTP_ENABLED' if you want to send emails set this to true. Else you can set this to false and also leave other `\_SMTP*` ENV blank,
- 'GRAFANA_SMTP_ADDRESS' hostname:port of your mailserver,
- 'GRAFANA_SMTP_USER' username of email with which you will log in,
- 'GRAFANA_SMTP_PASSWORD' password of 'GRAFANA_SMTP_USER' email,
- 'GRAFANA_SMTP_SKIP_VERIFY' set this to true if you want to skip ssl/tls/starttls verification,
- 'GRAFANA_SMTP_FROM_ADDRESS' email address which email recipient see,
- 'GRAFANA_SMTP_FROM_NAME' name which email recipient see,
- 'GRAFANA_EMAIL_ON_SIGN_UP' if you want to send welcome email when user signup to your grafana set this to true.

```
...
services:
  grafana:
    image: grafana/grafana:latest
    ports:
      - 3000:3000
    environment:
      - HOSTNAME=
      - GRAFANA_PUBLIC_URL=https://grafana.domain.com
      - GRAFANA_SMTP_ENABLED=true
      - GRAFANA_SMTP_ADDRESS=mail.domain.local:587
      - GRAFANA_SMTP_USER=
      - GRAFANA_SMTP_PASSWORD=
      - GRAFANA_SMTP_SKIP_VERIFY=false
      - GRAFANA_SMTP_FROM_ADDRESS=
      - GRAFANA_SMTP_FROM_NAME=Grafana
      - GRAFANA_EMAIL_ON_SIGN_UP=true
...
```

Telegraf configuratio we leave for later...

**2.5 Run script:**
Run:
`sudo bash deploy.sh`

If the last thing you see is when docker-compose is creating container and the successfully finished is everything OK!

Now you can create SSL for your exposed domains. (Certbot)

**2.6 Set up InfluxDB:**
Now reach your eposed domain of InfluxDB and you skould be presented with this: