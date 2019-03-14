# Prometheus Persistent Aggregation Gateway


helm upgrade prometheus-persistent-aggregation-pushgateway pushgateway-1.0.0.tgz --install --wait --timeout 600 --namespace monitoring
curl -d "#Help help text\n#TYPE dialog_open_counter counter\n dialog_open_counter{test=\"test3\", neu=\"okok\"} -10;" -X POST localhost:9090/v1/metrics