FROM alpine:3.22.0

# Install NFS utilities
RUN apk add --no-cache nfs-utils

# Create NFS exports directory
RUN mkdir -p /exports

# Copy default NFS export configuration (modify as needed)
COPY exports /etc/exports

# Start NFS server
CMD ["/usr/sbin/rpc.nfsd", "-N 2", "-N 3", "-N 4"]
