# preparation
## Create User Principals

Run the following command to create 2 user principals for "ava" and "bob".

    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme ava@BEIJING.COM"
    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw changeme bob@BEIJING.COM"