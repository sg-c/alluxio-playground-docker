# preparation
## Create User Principals

Run the following command to create 2 user principals for "ava" and "bob".

    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme ava@DOMAIN-1.COM"
    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme bob@DOMAIN-1.COM"