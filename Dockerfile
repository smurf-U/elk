FROM sebp/elk:latest

RUN mkdir -p /etc/logstash/patterns

ADD elk/logstash/python-apps /etc/logstash/patterns/python-apps
ADD elk/logstash/logging.yml /etc/logstash/logging.yml

RUN rm -f /etc/logstash/conf.d/*
ADD elk/logstash/conf.d/* /etc/logstash/conf.d/

VOLUME "/etc/logstash" "/etc/elasticsearch" "/opt/kibana/config" "/var/lib/elasticsearch" "/opt/logstash/data"

# PUSH 682115170512.dkr.ecr.us-east-1.amazonaws.com/elk:latest