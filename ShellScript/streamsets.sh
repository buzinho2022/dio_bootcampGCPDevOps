#!/bin/bash
# Variaveis para uso  
LOGIN_STREAMSETS="$1"
LOGIN_REGISTRY="$2"
SENHA_REGISTRY="$3"
TOKEN_STREAMSETS="$4"
STREAMSETS_CPU="$5"


echo "Versão Docker Compose"
export COMPOSE_VERSION=1.26.0

if ! usermod -aG wheel ${LOGIN_STREAMSETS}
then
    echo "Could not add user $USER to sudo group."
    exit 1
fi
echo "Useradd successfully"

echo "Installing Docker using convenience script..."
curl -fsSL https://get.docker.com -o get-docker.sh
DRY_RUN=1 sh ./get-docker.sh
if ! sh get-docker.sh
then
    echo "Docker Installation failed. Verify if convenience script is up-to-date."
    exit 1
fi
echo "Docker installation done successfully"
echo "Download and make docker-compose executable"
curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
cp -f /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

echo "Add ${LOGIN_STREAMSETS} to Group Docker."
usermod -aG docker ${LOGIN_STREAMSETS}
echo "Start Docker Service."
service docker start

echo "Create docker volumes for Streamsets Data Collector container."
if ! sudo -u ${LOGIN_STREAMSETS} docker volume create sdc-data
then
    echo "Docker data volume could not be created."
    exit 1
fi
if ! sudo -u ${LOGIN_STREAMSETS} docker volume create sdc-logs
then
    echo "Docker log volume could not be created."
    exit 1
fi
echo "Docker volumes created."
echo "Login into Container Registry."
if ! sudo -u ${LOGIN_STREAMSETS} docker login -u ${LOGIN_REGISTRY} -p ${SENHA_REGISTRY} magdatastrategy.azurecr.io
then
    echo "Could not connect in container registry. Check your credentials."
    exit 1
fi

echo "Connected to container registry."
echo "Download Streamsets Data Collector image"
sudo -u ${LOGIN_STREAMSETS} docker image pull magdatastrategy.azurecr.io/data-collector:4.4.0-dev
echo "Create docker-compose file to start SDC service"
# Criando arquivo compose para subir o serviço
cat <<EOF | sudo -u ${LOGIN_STREAMSETS} tee > /home/${LOGIN_STREAMSETS}/docker-compose.yml
version: "3.8"

services:
  sdc:
    deploy:
      mode: replicated
      replicas: 1
      resources:
        limits:
          cpus: '2'
          memory: 61440M
        reservations:
          memory: 61440M
      restart_policy:
        condition: on-failure
        max_attempts: 5
    hostname:
      $HOSTNAME
    environment:
      - SDC_CONF_https_port=18636
    image: magdatastrategy.azurecr.io/data-collector:4.4.0-dev
    extra_hosts:
     - datastrategyhmg3.servicebus.windows.net:10.253.55.6
     - ContratoDados.servicebus.windows.net:10.251.0.17
     - ContratoDados2.servicebus.windows.net:10.251.0.15
     - ContratoDadosProposta.servicebus.windows.net:10.251.0.19
     - magdatastrategyeventoscorporativoshmg.mongo.cosmos.azure.com:10.253.55.11
     - magdatastrategyeventoscorporativoshmg-brazilsouth.mongo.cosmos.azure.com:10.253.55.12
     - maginfradadoseventhubdev.servicebus.windows.net:10.253.55.4
     - maginfradadoseventhubhmg.servicebus.windows.net:10.253.55.15
     - maginfradadoseventhubprd.servicebus.windows.net:10.251.0.26
     - mageventoscorporativoscosmosprd.mongo.cosmos.azure.com:10.251.0.36
     - mageventoscorporativoscosmosprd-brazilsouth.mongo.cosmos.azure.com:10.251.0.37
     - magdatalakesc2hmg.dfs.core.windows.net:10.253.55.8
     - magdatalakepremiumstgdev.blob.core.windows.net:10.253.55.16
    ports:
      - 18636:18636
    volumes:
      # FOLDERS ##
      # Data files, pipelines, etc.
      - sdc-data:/data
      # SDC Log files
      - sdc-logs:/logs 
volumes:
  sdc-data:
    external: true
  sdc-logs:
    external: true
EOF

echo "Creating container for Streamsets Data Collector..."
sudo -u ${LOGIN_STREAMSETS} docker-compose -f /home/${LOGIN_STREAMSETS}/docker-compose.yml up -d
