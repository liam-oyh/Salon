#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

SERVICE_ID=0

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?"
  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim\n"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]$ && $SERVICE_ID_SELECTED < 6 && $SERVICE_ID_SELECTED > 0 ]]
  then
    SERVICE_ID=$SERVICE_ID_SELECTED
    APPOINTMENT
  
  else 
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
}

APPOINTMENT(){
 # get name
 SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")

 # get customer info
 echo -e "\nWhat's your phone number?"
 read CUSTOMER_PHONE
 CUSTOMER_NAME=$($PSQL "SELECT name FROM CUSTOMERS WHERE phone='$CUSTOMER_PHONE'")
 
 # if customer doesn't exist
 if [[ -z $CUSTOMER_NAME ]]
 then
   # get new customer name
   echo -e "\nI don't have a record for that phone number, what's your name?"
   read CUSTOMER_NAME

   # insert new customer
   INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
   
   # get customer_id
   CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
   
   # get appointment time
   echo -e "\nWhat time would you like your $SERVICE_NAME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
   read SERVICE_TIME
   
   # insert appointment
   INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

   # return appointment info
   echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  
 else
   # get customer_id
   CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
   
   # get appointment time
   echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
   read SERVICE_TIME
   
   # insert appointment
   INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

   # return appointment info
   echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
 fi
}



MAIN_MENU