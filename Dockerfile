FROM ballerina/ballerina-runtime:0.990.2
LABEL maintainer="dev@timschwalbe.de"
EXPOSE 9090 9797

COPY --chown=100:100 target/pushgateway.balx /home/ballerina 
COPY --chown=100:100 cert/ /home/ballerina/cert 
CMD ballerina run --observe pushgateway.balx
