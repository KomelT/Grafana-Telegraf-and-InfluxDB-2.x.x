# Grafana, Telegraf and InfluxDB 2.xx System monitoring

1. [Description, Logic and Use cases](#desc)</br>
   [1.2 Why was this created?](#why)</br>
   [1.3 Brief set up process](#brief)</br>
   [1.4 Logic behind](#logic)</br>
   [1.5 Use cases](#cases)</br>
   [1.5.1 Expose Grafana and InfluxDB on Internet](#e-all)</br>
   [1.5.2 Expose only Grafana on Internet](#only-grafana)</br>
2. [Installation](#install)</br>
   [2.1 Clone repository](#clone)</br>
   [2.2 Change directory](#dir)</br>
   [2.3 Edit Nginx data](#nginx)</br>
   [2.4 Edit docker data](#docker)</br>
   [2.5 Run script?](#script)</br>
   [2.6 Set up InfluxDB](#influx)</br>
   [2.7 Set up Telegraf](#telegraf)</br>
   [2.8 Set up Grafana](#grafana)</br>

## 1. Description, Logic and Use cases <a id="desc"></a>

### 1.2 Why was this created? <a id="why"></a>

This stack was created in wish to faster deploy Grafana, Telegraf and InfluxDB on a system and expose it on the internet. Then having ability to connect it with Telegraf from another system on web and capture metrics from two separate machines.

### 1.3 Brief set up process: <a id="brief"></a>

1. Edit and fill up necessary `docker-compose.yaml` and `nginx.conf` variables,
2. Run `deploy.sh` script, which does some work for you,
3. Create InfluxDB creditentials, (optional)
4. Edit docker-compose.yaml file with InfluxDB creditentials, (optional)
5. Create dashboard in Grafana!

### 1.4 Logic behind: <a id="logic"></a>

Telegraf gets system metrics (docker, net...) and sends it to InfluxDB.
Grafana fetchs data from InfluxDB and displays it.
If we want to expose also InfluxDB on internet we can also send metrics from servers outside our network.

### 1.5 Use cases: <a id="cases"></a>

**1.5.1 Expose Grafana and InfluxDB on Internet:** <a id="e-all"></a>
For this usecase just follow installation.

**1.5.2 Expose only Grafana on Internet:** <a id="only-grafana"></a>
If you don't want to expose InfluxDB on internet and just use it localy follow this:

1. Remove InfluxDB part from `nginx.conf`

```
...
server {
  listen 80;
  server_name influxdb.domain.local;

  location / {
    proxy_pass http://localhost:8086/;
  }
}
...
```

## 2. Installation <a id="install"></a>

**2.1 Clone repository:** <a id="clone"></a>
`git clone https://github.com/KomelT/Grafana-Telegraf-and-InfluxDB-2.x.x.git`

**2.2 Change directory:** <a id="dir"></a>
`cd Grafana-Telegraf-and-InfluxDB-2.x.x`

**2.3 Edit Nginx data:** <a id="nginx"></a>
At the end services Grafana and InfluxDB will be exposed to internet. // If you don't want to expose InfluxDB read what to do [HERE](#only-grafana).

Open Nginx configration:
`nano nginx.conf`

Replace Grafana domain:
Remove `grafana.domain.local` and write in your own Grafana domain.

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
Remove `influxdb.domain.local` and write in your own InfluxDB domain.

```
...
server {
  listen 80;
  server_name influxdb.domain.local;
...
```

**2.4 Edit docker data:** <a id="docker"></a>

Edit docker-compose file:
`nano docker-compose.yaml`

Grafana ENV explained:

- 'HOSTNAME' sets up hostname of Grafana container,
- 'GRAFANA_PUBLIC_URL' you tell your Grafana on what public url it will be exposed,
- 'GRAFANA_SMTP_ENABLED' if you want to send emails set this to true. Else you can set this to false and also leave other `SMTP` ENV blank,
- 'GRAFANA_SMTP_ADDRESS' hostname:port of your mailserver,
- 'GRAFANA_SMTP_USER' username of email with which you will log in,
- 'GRAFANA_SMTP_PASSWORD' password of 'GRAFANA_SMTP_USER' email,
- 'GRAFANA_SMTP_SKIP_VERIFY' set this to true if you want to skip ssl/tls verification,
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

Telegraf configuration we leave for later...

**2.5 Run script:** <a id="script"></a>
Run:
`sudo bash deploy.sh`

Now you can create SSL for your exposed domains if you want. (Certbot)

**2.6 Set up InfluxDB:** <a id="inlux"></a>
Now reach your exposed domain of InfluxDB and you should be presented with welcome screen.
Click 'Get started'.

1. Fill up all the data and don't forget it. For bucket name st 'telegraf_data'.
2. On left sidebar click on 'Data' section.
3. Click on 'API Tokens on top menu.'
4. Genera two API Tokens. Create read only one for Grafana and write only for Telegraf. For both is scope just bucket we have created before. Dont

**2.7 Set up Telegraf:** <a id="telegraf"></a>
Open terminal and run `sudo cat /etc/group | grup docker` and keep in mind the group number.

- 'user: telegraf:998' replace the 998 with number you got.
- 'TELEGRAF_HOSTNAME' In Grafana you will group by data by hostname so make it logical. Aka. from which machine is data comming,
- 'TELEGRAF_IDB_TOKEN' Paste the token which you have been given in InfluxDB,
- 'TELEGRAF_IDB_ORG' Type in organization which you created at the registration,
- 'TELEGRAF_IDB_BUCKET' Type in bucket name which you created at the registration.

```
...
  telegraf:
    image: telegraf:latest
    ports:
      - 8125:8125
      - 8092:8092/udp
      - 8094:8094
    user: telegraf:998
    environment:
      - HOST_PROC=/rootfs/proc
      - HOST_SYS=/rootfs/sys
      - HOST_ETC=/rootfs/etc
      - HOST_MOUNT_PREFIX=/rootfs
      - TELEGRAF_GET_INTERVAL=10s
      - TELEGRAF_SEND_INTERVAL=10s
      - TELEGRAF_HOSTNAME=
      - TELEGRAF_IDB_URL=influxdb:8086
      - TELEGRAF_IDB_TOKEN=
      - TELEGRAF_IDB_ORG=
      - TELEGRAF_IDB_BUCKET=
...
```

Now run `docker-compose up -d` to save changes in docker-compose.yaml file. Open InfluxDB, Explore section and select bucket you have created at registration. Now you can play in query builder and you should be also able to filter data by 'host' and there in should also be the hostname of you Telegraf instance.

**2.8 Set up Grafana:** <a id="grafana"></a>
Open Grafana.
**Deault login is u: admin p: admin**
On left menu find settings and then Data sources.
Add new Data source InfluxDB.
Query language should be Flux. [More about QL Flux](https://docs.influxdata.com/flux/)

Set these variables:

- URL http://influxdb:8086
- Uncheck basic auth
- Fill in Organization
- Fill in Token

When you click Save & Test it should show success.
This is it. Now you can build dashboards in Grafana.
Dont forget to read Grafana & InfluxDB Flux QL & Telegraf documentation.

**Thanks for staying till end. If there is any error, problem or room for imporovement please contact me on `tilen.komel10@gmail.com`. Best regards.**
