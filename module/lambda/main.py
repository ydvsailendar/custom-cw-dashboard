import boto3
import os

CSS = """
<style>
    table {
        width: 100%;
        border-collapse: collapse;
    }
    th, td {
        padding: 10px;
        text-align: left;
        border: 1px solid #ddd;
    }
    th {
        background-color: #f4f4f4;
    }

    .widget-container {
        width: auto;
        height: auto;
        min-width: 400px;
        min-height: 300px;
        max-width: 100%;
    }

    .high { color: red; }
    .medium { color: orange; }
    .low { color: green; }
</style>
"""


def handler(event, context):
    cloudwatch = boto3.client("cloudwatch")
    region = os.environ["CW_REGION"]

    try:
        alarm_list = list()
        alarms = cloudwatch.describe_alarms()

        for alarm in alarms["MetricAlarms"]:
            alarm_name = alarm["AlarmName"]
            alarm_state = alarm["StateValue"]
            alarm_description = alarm.get(
                "AlarmDescription", "No description available"
            )
            last_updated = alarm["StateUpdatedTimestamp"].strftime("%Y-%m-%d %H:%M:%S")
            severity = alarm_name.split("-")[-1].lower()

            if severity == "high":
                severity_class = "high"
            elif severity == "medium":
                severity_class = "medium"
            else:
                severity_class = "low"

            instance_id = os.environ["INSTANCE_ID"]
            instance_link = f"https://console.aws.amazon.com/ec2/v2/home?region={region}#InstanceDetails:instanceId={instance_id}"
            alarm_detail_url = f"https://console.aws.amazon.com/cloudwatch/home?region={region}#alarmsV2:alarm/{alarm_name}"
            metric_dashboard_url = f"https://console.aws.amazon.com/cloudwatch/home?region={region}#dashboards:name=observ-ec2-metrics"

            alarm_list.append(
                {
                    "alarm_name": alarm_name,
                    "status": alarm_state,
                    "description": alarm_description,
                    "last_updated": last_updated,
                    "severity": severity.capitalize(),
                    "severity_class": severity_class,
                    "instance_link": instance_link,
                    "alarm_detail_url": alarm_detail_url,
                    "metric_dashboard_url": metric_dashboard_url,
                }
            )

        table_html = """
        <table>
            <thead>
                <tr>
                    <th>Alarm Name</th>
                    <th>Severity</th>
                    <th>Status</th>
                    <th>Description</th>
                    <th>Last Updated</th>
                    <th>Instance Link</th>
                    <th>Metric Dashboard</th>
                </tr>
            </thead>
            <tbody>
        """

        for alarm in alarm_list:
            table_html += f"""
            <tr>
                <td>{alarm['alarm_name']}</td>
                <td class="{alarm['severity_class']}">{alarm['severity']}</td>
                <td>{alarm['status']}</td>
                <td><a href="{alarm['alarm_detail_url']}">{alarm['description']}</a></td>
                <td>{alarm['last_updated']}</td>
                <td><a href="{alarm['instance_link']}">View Instance</a></td>
                <td><a href="{alarm['metric_dashboard_url']}">View Metric Dashboard</a></td>
            </tr>
            """

        table_html += "</tbody></table>"
        return CSS + table_html
    except Exception as e:
        return {"error": str(e)}
