#!/bin/bash
# Start Nexus

usage () {
    echo "Usage: $(basename $0) (run | start | stop)" >&2
    exit 1
}

case $1 in
    run)
        docker run -d -p 8081:8081 --name nexus --restart unless-stopped -v nexus-data:/nexus-data sonatype/nexus3
        ;;
    start)
        docker start nexus
        ;;
    stop)
        docker stop --time=120 nexus
        ;;
    *) echo "Invalid Option"; usage ;;
esac

exit 0
