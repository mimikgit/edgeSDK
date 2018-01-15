cp ../build/index.js ./
sudo docker build -t drive .
sudo docker save -o drive.tar drive
sudo chmod 666 drive.tar
sudo docker rmi drive

