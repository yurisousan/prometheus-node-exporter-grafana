#!/bin/sh
# sudo yum update -y
sudo yum install wget -y

# criacao dos diretorios de download para colocar todos os pacotes
mkdir /home/vagrant/Downloads
cd /home/vagrant/Downloads

##############################################################################################
################################### PROMETHEUS-SERVER ########################################
##############################################################################################

# Download do prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.30.0/prometheus-2.30.0.linux-amd64.tar.gz

# Adicionando um user para o prometheus
useradd --no-create-home --shell /bin/false prometheus

# Criacao dos diretorios necessarios
mkdir /etc/prometheus
mkdir /var/lib/prometheus

# Dando permissao ao usuario criado como owner desses diretorios
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Extraindo o pacote
tar -xvzf /home/vagrant/Downloads/prometheus-2.30.0.linux-amd64.tar.gz

# Renomeando o diretorio
mv prometheus-2.30.0.linux-amd64 prometheuspackage

# Copiando os arquivos para seus respectivos
cp prometheuspackage/prometheus /usr/local/bin/
cp prometheuspackage/promtool /usr/local/bin/

# Alterando o owner desses diretorios
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Copiando as libs do console para o diretorio
cp -r prometheuspackage/consoles /etc/prometheus
cp -r prometheuspackage/console_libraries /etc/prometheus


# Alterando o owner desses diretorios
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

# Criando o arquivo de configuracao do prometheus
echo "global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter_centos'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']" > /etc/prometheus/prometheus.yml

# Alterando o owner do arquivo
chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Configurando o Service do prometheus
echo "[Unit]
  Description=Prometheus
  Wants=network-online.target
  After=network-online.target

  [Service]
  User=prometheus
  Group=prometheus
  Type=simple
  ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

  [Install]
  WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service

# Reload do systemd
sudo systemctl daemon-reload

# Startando o servico do prometheus
sudo systemctl start prometheus

##############################################################################################
##################################### NODE EXPORTER ##########################################
##############################################################################################

# Downlad do pacote
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz

# Extraindo o pacote
tar -xvzf node_exporter-1.2.2.linux-amd64.tar.gz

# Criando um user para o node_exporter
sudo useradd -rs /bin/false nodeusr

# Mover o binario para /bin
sudo mv node_exporter-1.2.2.linux-amd64/node_exporter /usr/local/bin/

# Criando um arquivo de configuracao para o node_exporter
echo "[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node_exporter.service

# Reload do systemd
sudo systemctl daemon-reload

# Startando o servico do prometheus
sudo systemctl start node_exporter

# Habilitando para startar em todo boot
sudo systemctl enable node_exporter

# restartando o prometheus server
sudo systemctl restart prometheus

##############################################################################################
######################################## GRAFANA #############################################
##############################################################################################

# Download do pacote
wget https://dl.grafana.com/oss/release/grafana-8.1.5-1.x86_64.rpm

# instalando o grafana
sudo yum install grafana-8.1.5-1.x86_64.rpm -y

# adicionando o datasource do prometheus
echo "apiVersion: 1
 
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: localhost:9090" > /etc/grafana/provisioning/datasources/datasource.yaml

# # Adicionando um dashboard do prometheus 2.0 para teste
# echo "apiVersion: 1

# providers:
#  - name: 'Prometheus Metrics'
#    orgId: 3662
#    folder: 'General'
#    options:
#      path: /var/lib/grafana/dashboards" > /etc/grafana/provisioning/dashboards/dashboard.yaml

# Reload do systemd
sudo systemctl daemon-reload

# start no grafana service
sudo systemctl start grafana-server

# para rodar em todo o boot
sudo systemctl enable grafana-server