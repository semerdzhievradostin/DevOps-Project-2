![image](https://user-images.githubusercontent.com/104006126/217023267-c276399b-69b1-4922-a4fa-e24778e1bb39.png)
A set of three machines , Spin up RabbitMQ single-node cluster (Brk)
Enable the monitoring of the single-node cluster (either by enabling a plugin or by running additional container)
Spin up a discoverer container (Prd) for the animal-facts topic/exchange by using the appropriate repository
o	for RabbitMQ – https://hub.docker.com/repository/docker/shekeriev/rabbit-discoverer (producer)
Spin up an observer container (Cns) for the animal-facts topic/exchange by using the appropriate repository
o	for RabbitMQ – https://hub.docker.com/repository/docker/shekeriev/rabbit-observer (consumer)
Spin up a Prometheus instance (Pr) and 
o	Set it to collect data from the single-node cluster
o	And to collect data from the discoverer application
•	Spin up a Grafana instance (Gr) and set it to use the Prometheus instance as a data source

Configuration Management
Do a basic (installed and running) installation of Docker on VM1
The user in use (vagrant or another one) must be a member of the docker group
Do a basic (installed and running) installation of Apache (+PHP +libraries) on VM2
Add two virtual hosts by port – 8081 and 8082
Deploy both applications (app1 and app4) files to the corresponding folders of the virtual hosts
Do a basic (installed and running) installation of MariaDB/MySQL on VM3
Make sure the service is listening on all interfaces (should be accessible from VM2)
Deploy applications’ databases
Make sure that VM2 and VM3 can reach each other by name

Monitoring
Create a simple visualization of a metric of the selected middleware 
Create a simple visualization of one of the metrics (discovered_facts_total or time_spent_total) of the discoverer application



Steps to execute in order to work :

vagrant up 
After all VMs are up :

1.vagrant ssh docker 
2. cd /vagrant/terraform-all
3. terraform init
4. terraform plan
5. terraform apply
6. After all containers are up check if rabbit-discoverer and observer are up using docker container ls
If they are exited execute terraform apply again . 
If they are up execute
docker container restart rabbit-discoverer and docker container restart rabbit-observer
7.Enter http://192.168.99.100:3000/dashboard/import in order to import RabbitMQ monitoring dashboard 
8. Paste the following in the box below Import via grafana.com :
https://grafana.com/grafana/dashboards/10991-rabbitmq-overview/?fbclid=IwAR3XiHn_-GVl0EfGz11IOehRepes6QDP1r8GUTulReGhetfAUT8TDRq_q1o
9.Above the Import button you must choose Prometheus .
10. The following should be visible now :
 11. In order to get metrics from the discoverer, go to http://192.168.99.100:3000/dashboards --> New Dashboard  Add new Panel  Add the below query 
discovered_facts_created{instance="rabbit-discoverer:8000"} 
Or this one 
discovered_facts_total{job="rabbitmq-discoverer"}

 
Enter : http://192.168.99.101:8081/
 
Enter http://192.168.99.101:8082/
 

Prometheus : http://192.168.99.100:9090/targets?search=
 

Observer http://192.168.99.100:5000/ :  
