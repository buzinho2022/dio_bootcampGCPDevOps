#!/bin/bash

echo "Criando as imagens docker ...."

docker build -t rodrigomotadevops/k8s-backend:1.0 backend/.
docker build -t rodrigomotadevops/k8s-database:1.0 database/.

echo "Realiza o push das imagens para o docker hub ...."

docker push rodrigomotadevops/k8s-backend:1.0
docker push rodrigomotadevops/k8s-database:1.0

echo "Criando os serviços no cluster kubernetes...."

kubectl apply -f ./services.yaml

echo "Criando os deployments no cluster kubernetes...."

kubectl apply -f ./deployments.yaml

echo "Aplicando os arquivos de configuração do kubernetes ...."



