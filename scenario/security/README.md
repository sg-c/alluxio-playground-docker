# preparation
## Create User Principals

Run the following command to create 2 user principals for "ava" and "bob".

    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw ${KERB_USER_PASS} ava@${REALM}"
    docker exec security-kdc-1 kadmin -p admin/admin -w admin -q "addprinc -pw ${KERB_USER_PASS} bob@${REALM}"