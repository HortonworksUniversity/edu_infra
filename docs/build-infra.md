### *** E D U   A D M I N *** 

#DISCLAIMER 
EDU Admin is for training purposes only and is to be used only # in support of approved training. The author assumes no liability # for use outside of a training environments. Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

Title: build-base-env.txt 
Author: WKD
Date: 200916 
Purpose: Detailed instructions on building the base environment.

#PURPOSE 
This is a training environment intended to support the CDP classes. This is a complex environment built with a lot of dockerfiles, but it is capable of support many different educational scenarios.

#PREPS 
Access the Github edu_admin_env.
1. Ask for access to CLDR github. 
2. Clone the github repo for the edu-docker

	% mkdir ~/src
	% cd ~/src
	% git clone URL
 
#SETUP EC2 INSTANCE 
Instructions for setting up the Ubuntu Docker Server. We use Ubuntu 16.04 as this is the recommended OS for Docker.
1. Open a JIRA ticket against EDOPS. Capture the ticket number.
2. Launch a AWS EC2 instance. Use the Bob the Build site.

	http://edulabs.hortonworks.com/bobthebuilder/job/Launch-AMI-With-tags/

3. Complete the build page. This will create all of the required tags and use the correct AMI.
	tol
        JIRA ticket number TINFRA-35 

3. Complete the build page. This will create all of the required tags and use the correct AMI.

        PROJECT EDOPS 
        TICKET NUMBER  135
        LOCATION ncalifornia
        NO_OF_VMS 1 
        TRAINER_INTIALS WKD
        CUSTOMER  EDU 
        AUTO TERM 14 
        PURPOSE DevOps
        AWS_AMI_ID ami-09eb5e8a83c7aa890  #Ubuntu 16.04
        AWS_Instance_Size r5.2xlarge
        AWS_root_volume_size 128 

4. Recommend associating an EIP in Route53 under hdplabs. This makes life easier as you stop and start the instance.

	Route 53
        Zone hdplabs.com
        DNS  edu-admn.hdplabs.com

5. Add your Internet Gateway IP Address to the security group
6. Login and validate your private key. I have set my default id_rsa to the training-keypair.pem.

        % ssh -i ~/.ssh/training-keypair.pem ubuntu@hostname
        % exit

#SETUP DOCKER SERVER
1. On your local host create the tar file backend for docker setup. There are two directories that must be placed onto the AWS EC2 instance, one with conf files and the other with admin scripts. 
2. Put the setup docker files into a tar file.

	% cd ~/src/edu-docker/HDP/docker-server
	% tar cvf /tmp/edu-docker.tar conf sbin

3. Copy over the tar file

	% scp /tmp/*.tar ubuntu@hostname:/home/ubuntu/

4. Login onto the AWS instance

	% ssh ubuntu@hostname 

5. Extract the edu-docker file

	% tar xvf edu-docker.tar

6. Cleanup

	% rm *.tar 


#SETUP DATA
NOTE: If data is required it can be pulled from the AWS S3 bucket. The bucket permissions will need to be changed to allow the copy. Please change them back.

1. The data is pulled in from an S3 bucket. Create a data directory on the ubuntu server. This will be mounted into /var/data on each node.

	% mkdir data
	% cd data

2. Download the zip files from the S3 bucket.

	% wget https://edu-data-wkd.s3-us-west-1.amazonaws.com/books.zip 
	% wget https://edu-data-wkd.s3-us-west-1.amazonaws.com/cloudair.zip 
	% wget https://edu-data-wkd.s3-us-west-1.amazonaws.com/latin.zip 
	% wget https://edu-data-wkd.s3-us-west-1.amazonaws.com/nyse.zip 
	% wget https://edu-data-wkd.s3-us-west-1.amazonaws.com/telco.zip 

3. Unzip these files.

	% unzip books.zip

4. Delete the zip files
	
	% rm *.zip

#INSTALL DOCKER 
1. Run setup for the backend. 
IMPORTANT This requires you to have an account on github, you will need to provided your userid and password to download. Sudo is built into this script, run as ubuntu. 
IMPORTANT Validate the setup file for the correct github repo to clone.

	% ./sbin/setup-ubuntu-docker.sh

2. Provide login for github.

3. You must logout and log back in to setup docker environment. 
IMPORTANT Ensure you do this step.

	% exit 


4. Validate

	% ssh ubuntu@hostname
	% docker container ls

#CHECK GITHUB 
NOTE: The git code should already be in place. This checks for branch and access. You will need acces to the github repo. The script is installed for a ssh pull. If you do not have ssh then you need to edit the script to pull using HTTP.
 
1. Go to the src directory for the repo

	% cd ~/src/edu_admin_env
	% git branch 
	% git pull

#BUILD IMAGES
Build and repo the images.
1. Run the build. Then review the list of images.

	% edu-admin.sh build

2. If you are submitting the images to a repo. There may be a public repo at Docker hub for wmdailey. I normally skip this task.

	% edu-admin.sh repo

#RUN CONTAINERS
This setups for the admn environment. 
1. Run containers

	% edu-admin.sh network
	% edu-admin.sh run ansible 

3. Validate your cli environment from ubuntu. 

	% ssh sysadmin@ansible
	% sudo ambari-server status 
	% exit
	% ssh sysadmin@client01 
	% exit

3. Validate desktop access to Ubuntu Mate. Ensure the ssl is working.

	https://hostname.domain
	login with our standard password

#SETUP DESKTOP
Customizations to desktop
1. Arrange the icons on the desktop
2. Change the color of the terminal to black font and white background 
3. Find Google chrome in applications list and select as browser 
4. Set standard password for keychain 
5. Set Google chrome as default browser 
6. Restart the docker image
	% edu-admin.sh stop
	% edu-admin.sh start

#BUILD AMI 
Create an AMI 
	EDU-ADMIN-200514 
