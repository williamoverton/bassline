#cloud-boothook
# Configure Yum, the Docker daemon, and the ECS agent to use an HTTP proxy

# Specify proxy host, port number, and ECS cluster name to use
PROXY_HOST="${proxy_dns}"
PROXY_PORT="${proxy_port}"
CLUSTER_NAME="${ecs_cluster_name}"

# Set Yum HTTP proxy
echo "proxy=http://$PROXY_HOST:$PROXY_PORT" >> /etc/yum.conf

# Set Docker HTTP proxy
# echo "export HTTP_PROXY=http://$PROXY_HOST:$PROXY_PORT/" >> /etc/sysconfig/docker
# echo "export NO_PROXY=localhost,169.254.169.254,/var/run/docker.sock,10.0.0.0/8" >> /etc/sysconfig/docker


# Set ECS agent HTTP proxy
echo "ECS_CLUSTER=$CLUSTER_NAME" >> /etc/ecs/ecs.config
echo "HTTP_PROXY=http://$PROXY_HOST:$PROXY_PORT/" >> /etc/ecs/ecs.config
echo "NO_PROXY=localhost,169.254.169.254,169.254.170.2,/var/run/docker.sock,10.0.0.0/8" >> /etc/ecs/ecs.config

echo "env HTTP_PROXY=http://$PROXY_HOST:$PROXY_PORT/" >> /etc/init/ecs.override
echo "env NO_PROXY=localhost,169.254.169.254,169.254.170.2,/var/run/docker.sock,10.0.0.0/8" >> /etc/init/ecs.override

mkdir -p /etc/systemd/system/docker.service.d/
echo '[Service]' >> /etc/systemd/system/docker.service.d/http-proxy.conf
echo 'Environment="HTTPS_PROXY=http://proxy-dev-sandbox.bassline.internal:9000/" "HTTP_PROXY=http://proxy-dev-sandbox.bassline.internal:9000/" NO_PROXY="localhost,169.254.169.254,169.254.170.2,/var/run/docker.sock,10.0.0.0/8"' >> /etc/systemd/system/docker.service.d/http-proxy.conf

# Reload docker config
sudo systemctl daemon-reload
