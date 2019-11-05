Readme.md
In Zabbix:
Created host Zabbix server2 with ip 192.168.0.101 with template "Template Module Linux CPU by Zabbix agent"

On 1st server run the command

/jmeter/apache-jmeter-5.1.1/bin/jmeter -n -t /jmeter/build-web-test-plan.jmx


Result:
Zabbix server2	Load average is too high (per CPU load over 1.1 for 5m)