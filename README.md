# BSP Auto
Retrieve price history for selected cars on BSP Auto website.

## Principle ##

* Retrieve your search
* Select your cars with the best price
* Print the results in a CSV file

## Parameters ##

You can change some parameters in the script :
* `URL` : Link to the rental car search (http://www.bsp-auto.com/fr/list.asp? with POST values in GET parameters)
* `voitures` : Cars you are looking for in a Shell Array (index array is important)
* `current_price`: Current price of your car (manual entry). Pretty useful to make a clear view on your graph

## Files ##

These are the files generated :
* bsp-auto.sh : Shell script
* bsp-auto.curl : HTML file retrieved from bsp-auto website
* bsp-auto.result : Intermdiate file generate
* bsp-auto : Final gerated file in CSV format

## Run the script ##

```
./bsp-auto.sh
```

## Show result ##

```
cat bsp-auto
```

```
date,SEAT IBIZA*,RENAULT CLIO*,VW POLO*,RENAULT CAPTUR GPS*
2018-01-12 16:17:02,373,481,508,885
2018-01-12 16:13:59,373,481,508,885
```

## Go deeper in the script ##

These are some tracks to make a better script :
* Delete similar rows on pricing
* Limit the size of generated files

## Further looking ##

### Schedule the price collect ###
```
echo "0/15 * * * * root /bin/bash /opt/bsp-auto/bsp-auto.sh" > /etc/cron.d/bsp-auto
systemctl restart crond
```
Becareful of the generated files because they will grow forever.

### Expose the result on internet ###
*This example is for Apache 2.4*
```
yum install -y httpd
mkdir /var/www/bsp-auto
ln -sf /opt/bsp-auto/bsp-auto /var/www/bsp-auto/bsp-auto
chown -R  apache:apache /var/www/bsp-auto
cat << EOF > /etc/httpd/conf.d/virtualhost.conf
<VirtualHost *:80>
  DocumentRoot /var/www/bsp-auto

  <Directory /var/www/bsp-auto>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
  </Directory>

</VirtualHost>
EOF
systemctl restart httpd
```

### Import in Google Spreadsheet ###
You can expose your file on the web and retrieve it in a Google Spreadsheet in order the make a graph of the price collected from bsp-auto.
In a Spreadsheet shell, call your url exposed with the formula `=importData`
