FROM debian:latest
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
    net-tools iproute2 \
    inetutils-ping inetutils-traceroute iputils-arping \
    curl wget \
    tcpdump nmap \
    vim nano \
    dnsutils \
    ssh \
    isc-dhcp-client
