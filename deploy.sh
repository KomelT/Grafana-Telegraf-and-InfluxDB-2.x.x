#!/bin/sh

echo ""
echo ""

if [ "$EUID" -ne 0 ]
  then echo "Please run script as root or with sudo!"
  exit
fi

# Create needed folders
mkdir -p /appdata/telegraf && echo "Telegraf folder created successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

mkdir -p /appdata/grafana/etc-grafana && echo "Grafana folder 1 created successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

mkdir -p /appdata/grafana/var-lib-grafana && echo "Grafana folder 2 created successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

mkdir -p /appdata/influxdb && echo "InfluxDB folder created successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

chmod -R 776 /appdata/grafana && echo "Rights successfully altered to Grafana folder!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

# Get Telegraf configuration file
cp configuration/telegraf/telegraf.conf /appdata/telegraf/telegraf.conf && echo "Configuration file for Telegraf downloaded successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi


# Get Grafana configuration file
cp configuration/grafana/grafana.ini /appdata/grafana/etc-grafana/grafana.ini && echo "Configuration file for Grafana downloaded successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

cp -r configuration/grafana/provisioning /appdata/grafana/ && echo "Provisioning configuration file for Grafana downloaded successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

cp nginx.conf /etc/nginx/sites-available/grafana-monitoring && echo "Nginx config copied successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

ln -s /etc/nginx/sites-available/grafana-monitoring /etc/nginx/sites-enabled/grafana-monitoring && echo "Symbolic link created successfully!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

nginx -t && service nginx restart && echo "Nginx config is OK!"

if [ $? -ne 0 ]; then
    echo "Exitting because of error!"
    exit 1
fi

docker-compose up -d