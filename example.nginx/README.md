curl -sSL https://get.docker.com/ | sh

sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server