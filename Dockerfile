FROM alpine:3.22.0

# Install NFS utilities
RUN apk add --no-cache nfs-utils

# Create NFS exports directory
RUN mkdir -p /exports

# Copy default NFS export configuration (modify as needed)
COPY exports /etc/exports
COPY run_nfs.sh /usr/local/bin/

# Start NFS server
CMD ["/usr/local/bin/run_nfs.sh"]
