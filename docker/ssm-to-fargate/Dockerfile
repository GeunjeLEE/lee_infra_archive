FROM centos:7

COPY run.sh /run.sh

RUN mkdir /tmp/ssm \
    && curl https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm -o /tmp/ssm/amazon-ssm-agent.rpm \
    && yum install -y /tmp/ssm/amazon-ssm-agent.rpm \
    && cp /etc/amazon/ssm/seelog.xml.template /etc/amazon/ssm/seelog.xml

CMD ["bash", "run.sh"]
