echo "Criando as imagens docker ...."

docker build -t rodrigomotadevops/k8s-backend:1.0 backend/.
docker build -t rodrigomotadevops/k8s-database:1.0 database/.

echo "Realiza o push das imagens para o docker hub ...."

docker push rodrigomotadevops/k8s-backend:1.0
docker push rodrigomotadevops/k8s-database:1.0


echo "Aplicando os arquivos de configuração do kubernetes ...."



#docker build -t rodrigomotadevops/k8s-