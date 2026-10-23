FROM alpine:3.22.0

# Install NFS utilities
RUN apk add --no-cache nfs-utils mariadb-client bash openssh-client rsync lsyncd

# Config ssh
RUN mkdir -p /root/.ssh
RUN echo "Host *" > /root/.ssh/config
RUN echo "    StrictHostKeyChecking no" >> /root/.ssh/config

# Create NFS exports directory
RUN mkdir -p /exports

# Copy default NFS export configuration (modify as needed)
COPY exports /etc/exports
COPY run_nfs.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_nfs.sh

# Start NFS server
CMD ["/usr/local/bin/run_nfs.sh"]
