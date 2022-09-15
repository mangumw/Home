----Running Birst Cloud Agent as an executable----
Windows
Run BirstCloudAgent_HOME\bin\Agent.bat
Mac/Linux
Run BirstCloudAgent_HOME\bin\Agent

----Running Birst Cloud Agent as a Windows service----

First Time Installation
	Optional Customization:
		Modify the SERVICE_ID, SERVICE_NAME and SERVICE_DESCRIPTION field in BirstCloudAgent_HOME/agent.properties to change the ID, name, and description of the service installed. If configuration is not provided, it will automatically pick "BirstCloudAgent"(along with a number if there is duplicate) as the name and ID. If the properties does not exist, running the first time installation will automatically populate the properties with auto-generated fields.
	1) Run "BirstCloudAgent_HOME\service\Agent Service Install.bat" as administrator.
	
	The service will automatically start up.

Uninstall
	1) Run Windows Command Prompt as an administrator and run: "SC DELETE [BirstCloudAgent_ID]"

Update Agent
    You must be an account admin OR the owner of the agent(person who downloaded the agent) to upgrade an agent.
    1) Ensure that the Birst Cloud Agent is running.
    2) Login to Birst and navigate to Admin -> Agent module.
    3) Select the agent that needs to be updated and click "Upgrade Agent".
    Note: You can check in the newest agent logs to see if it is actively working on any tasks. If there are no tasks, you should see mainly "No request to be served." in the recent logs.

Troubleshooting
	The logs for the service's installation and runtime can be found in: BirstCloudAgent_HOME\bin\logs. Use the content of the logs to troubleshoot.

	1) Service with id/name already exists.
	This indicates Birst Cloud Agent service has already been installed to this machine with the same name you have given in agent.properties. The PROPERTY_ID/PROPERTY_NAME in agent.properties will need to be renamed.
	NOTE: If PROPERTY_ID/PROPERTY_NAME/PROPERTY_DESCRIPTION properties does not exist in your existing agent.properties, it will automatically be added after the first time installation. If PROPERTY_ID/PROPERTY_NAME is empty during the first time installation, we will automatically save the auto-generated service name/ID into agent.property file.

	2) Service is already running.
	This indicates that there is already existing service running the service executable. The service mentioned must be stopped before a new service can be installed.
	
----Proxy configuration in Birst cloud agent----
You can define following proxy properties in agent.properties file to configure proxy in Birst cloud agent:
- com.birst.proxy.host : Host name or IP address of your proxy server
- com.birst.proxy.port : Port number of your proxy server
- com.birst.proxy.nonProxyHosts : List of host names/ip addresses you want to bypass proxy. If there are multiple hosts then you need to delimit them with pipe sign (|) 

If your proxy server supports basic authentication then you need to set below properties in addition to above mentioned properties:
- com.birst.proxy.username : User name for proxy authentication
- com.birst.proxy.password : Password for proxy authentication

----setting Transaction Isolation Level property in agent.properties---- 
Following values can be set for property com.birst.connection.transactionIsolationLevel in agent.properties file. 
1) TRANSACTION_READ_UNCOMMITTED
   - Dirty read, nonrepeatable reads and phantoms can occur.
2) TRANSACTION_READ_COMMITTED 
   - Dirty read can not occur. Nonrepeatable reads and phantoms can occur. 
3) TRANSACTION_REPEATABLE_READ
   - Dirty read and nonrepeatable reads can not occur. Phantoms can occur.
4) TRANSACTION_SERIALIZABLE
   - Dirty read, nonrepeatable reads and phantoms can not occur.  
   
----setting connection clean up interval in agent.properties----
- The default value of property com.birst.connection.connectionCleanUpInterval is 10 minutes.
- This property is used to clean up the latent connections for the given time interval. 
- Only positive integers are considered to be valid input. For invalid input, clean up is done in the default time interval.

----setting auto commit property in agent.properties----
- The default value of property com.birst.connection.autoCommit is true.
- This property is used to configure auto commit property of database connection.  
