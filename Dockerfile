FROM ballerina/ballerina-runtime:0.990.3
LABEL maintainer="dev@timschwalbe.de"
EXPOSE 9090 9797
COPY --chown=100:100 target/pushgateway.balx /home/ballerina
CMD ballerina run --observe pushgateway.balx
