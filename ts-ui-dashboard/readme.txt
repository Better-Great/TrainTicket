# =============================================================================
# NOTE: This is NOT end-user documentation.
# It is a scratch list of nginx location / proxy_pass fragments for backend
# services. Active nginx config for Docker is nginx.conf in this directory.
#
# WHERE IS THE UI?
#   - Admin dashboard home: static/index.html  (title: "TrainTicket Admin")
#   - Client flows: static/client_login.html, client_ticket_book.html, etc.
#   - Run locally: ./run-local.sh  → http://127.0.0.1:8080/
# =============================================================================

# For account and verification

        location /register {
            proxy_pass   http://ts-register-service:12344;
        }
        location /login {
            proxy_pass   http://ts-login-service:12342;
        }
        location /logout {
            proxy_pass   http://ts-login-service:12342;
        }
        location /verification/generate {
            proxy_pass   http://ts-verification-code-service:15678;
        }




        # For station service

        location /station/create {
            proxy_pass   http://ts-station-service:12345;
        }
        location /station/exist {
            proxy_pass   http://ts-station-service:12345;
        }
        location /station/delete {
            proxy_pass   http://ts-station-service:12345;
        }




        # For train service

        location /train/create {
            proxy_pass   http://ts-train-service:14567;
        }
        location /train/retrieve {
            proxy_pass   http://ts-train-service:14567;
        }
        location /train/update {
            proxy_pass   http://ts-train-service:14567;
        }
        location /train/delete {
            proxy_pass   http://ts-train-service:14567;
        }




        # For config service

        location /config/create {
            proxy_pass   http://ts-config-service:15679;
        }
        location /config/query {
            proxy_pass   http://ts-config-service:15679;
        }
        location /config/update {
            proxy_pass   http://ts-config-service:15679;
        }
        location /config/delete {
            proxy_pass   http://ts-config-service:15679;
        }




        # For contacts service

        location /createNewContacts {
            proxy_pass   http://ts-contacts-service:12347;
        }

        location /deleteContacts {
            proxy_pass   http://ts-contacts-service:12347;
        }

        location /saveContactsInfo {
            proxy_pass   http://ts-contacts-service:12347;
        }

        location /findContacts {
            proxy_pass   http://ts-contacts-service:12347;
        }




        # For order service

        location /createNewOrders {
            proxy_pass   http://ts-order-service:12031;
        }

        location /cancelOrder {
            proxy_pass   http://ts-order-service:12031;
        }

        location /saveOrderInfo {
            proxy_pass   http://ts-order-service:12031;
        }

        location /alterOrder {
            proxy_pass   http://ts-order-service:12031;
        }

        location /queryOrders {
            proxy_pass   http://ts-order-service:12031;
        }

        location /calculateSoldTickets {
            proxy_pass   http://ts-order-service:12031;
        }




        # For travel service

        location /travel/create {
            proxy_pass   http://ts-travel-service:12346;
        }
        location /travel/retrieve {
            proxy_pass   http://ts-travel-service:12346;
        }
        location /travel/update {
            proxy_pass   http://ts-travel-service:12346;
        }
        location /travel/delete {
            proxy_pass   http://ts-travel-service:12346;
        }
        location /travel/query {
            proxy_pass   http://ts-travel-service:12346;
        }


    