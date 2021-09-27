# Prometheus + node_exporter + Grafana
This repo is a simple config to up a virtual box vm (centos7) with Prometheus, Node_Exporter - to self metrics - and Grafana to visibility

## Requirements
Make sure these software have been installed
- Vagrant
- Virtualbox
## How to use
Clone this repo
```bash
git clone https://github.com/yurisousan/prometheus-node-exporter-grafana.git
```
Access the directory
```bash
cd prometheus-node-exporter-grafana
```
And execute the vagrant:
```bash
vagrant up
```
## Access and Visualize
To access the prometheus GUI
```bash
192.168.0.156:9090
```
To access the node_exporter metrics
```bash
192.168.0.156:9100/metrics
```
To access the Grafana GUI
```bash
192.168.0.156:3000
```
To see the targets confgiured in prometheus
```bash
192.168.0.156:9090/targets
```