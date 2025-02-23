#!/bin/bash

dnf update -y

dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<html><body><h1>Hello from EC2 Instance!</h1></body></html>" > /var/www/html/index.html

dnf install -y amazon-cloudwatch-agent
cat <<-EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "observ-ec2",
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 10
      },
      "procstat": [
        {
          "pid_file": "/var/run/httpd/httpd.pid",
          "measurement": ["pid_count"],
          "metrics_collection_interval": 10
        }
      ]
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "${log_group}",
            "log_stream_name": "access_log"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "${log_group}",
            "log_stream_name": "error_log"
          }
        ]
      }
    }
  }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
