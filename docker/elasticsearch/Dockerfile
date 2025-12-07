FROM docker.elastic.co/elasticsearch/elasticsearch:8.11.0

ENV discovery.type=single-node
ENV xpack.security.enabled=false
ENV ES_JAVA_OPTS=-Xms512m -Xmx512m

EXPOSE 9200 9300

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -s http://localhost:9200/_cluster/health | grep -q "green\|yellow" || exit 1

CMD ["./bin/elasticsearch"]
