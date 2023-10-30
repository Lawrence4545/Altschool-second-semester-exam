# Altschool-second-semester-exam
#################Automated LAMP Stack Provisioning with Vagrant and Ansible###############

This project automates the provisioning of two Ubuntu-based servers, "Master" and "Slave," using Vagrant. The "Master" node deploys a LAMP (Linux, Apache, MySQL, PHP) stack using a reusable and readable bash script. Additionally, an Ansible playbook is employed to execute the bash script on the "Slave" node and set up a cron job for server uptime monitoring.


#########Prerequisites##########

Before running this automation, make sure you have the following software installed on your system:

1. Vagrant

2. VirtualBox

3. Ansible

4. 
#################################################




###########Getting Started##################



Clone this repository to your local machine:
git clone https://github.com/Lawrence4545/Altschool-second-semester-exam.git

Navigate to the project directory:
cd Altschool-second-semester-exam

Update the Vagrantfile with the desired server configurations, such as IP addresses, CPU, and memory allocations.

Review and modify the Ansible playbook (ansible/playbook.yml) as needed for your specific environment.



###################################################################




#######Provisioning the Servers###########3

Provision the "Master" and "Slave" servers using Vagrant:

1. vagrant up
This command will create two virtual machines according to the Vagrantfile configuration.

2. Connect to the "Master" server
vagrant ssh master

OR you run ./script.sh script to authomate that for you.




########################################################




##########Setting Up the LAMP Stack on the "Master" Node###########3


Inside the "Master" server, navigate to the project directory:

cd /My-app
Execute the bash script to set up the LAMP stack:

./provision.sh
This script will:

Clone a PHP application from GitHub.
Install all necessary packages.
Configure the Apache web server and MySQL.
Once the script completes successfully, your LAMP stack is ready on the "Master" server.



#####################################################################


#######Running Ansible Playbook on the "Slave" Node########


On your local machine, run the Ansible playbook to configure the "Slave" node:

ansible-playbook -i ansible/hosts ansible/playbook.yml
This playbook will:

Execute the bash script on the "Slave" node.
Create a cron job to check the server's uptime every day at 12 am.
Access the PHP application deployed on the "Slave" server using its IP address.


##############################################



Server Uptime Monitoring
The server uptime monitoring is scheduled to run daily at 12 am on the "Slave" node as configured by the Ansible playbook.



#######Conclusion###########



This project automates the provisioning of LAMP servers using Vagrant and Ansible, making it easier to deploy and manage your web applications. Feel free to customize the configurations to fit your specific requirements and enjoy a more streamlined development environment.





