cp ../build/index.js ./
sudo docker build -t example .
sudo docker save -o example.tar example
sudo chmod 666 example.tar
sudo docker rmi example

