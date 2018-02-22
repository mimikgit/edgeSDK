cp ../build/index.js ./
sudo docker build -t example-v1 .
sudo docker save -o example-v1.tar example-v1
sudo chmod 666 example-v1.tar
sudo docker rmi example-v1
