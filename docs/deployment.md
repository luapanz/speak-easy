# Deployment

For configure the app you need composer to be installed. See the guide how to install it
[here](https://getcomposer.org/doc/00-intro.md)

phing library is used for building. https://www.phing.info/

To deploy the app:

1. Copy build.properties.dist file to build.properties 

`cp build.properties.dist build.properties`

and set up all the properties in the file

2. Run configure job

`bin/phing configure`

After that, you'll have all the configuration files created.

3. Run the server 

`rails server -e :environment`

for example: 

`rails server -e development`