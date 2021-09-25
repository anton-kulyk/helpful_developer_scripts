#!/bin/bash

BASENAME=$1

function pwdgen(){
	SYMBOLS=""
	for symbol in {A..Z} {a..z} {0..9}; do SYMBOLS=$SYMBOLS$symbol; done
	SYMBOLS=$SYMBOLS
	PWD_LENGTH=30
	PASSWORD=""
	RANDOM=256
	
	for i in `seq 1 $PWD_LENGTH`
		do
			PASSWORD=$PASSWORD${SYMBOLS:$(expr $RANDOM % ${#SYMBOLS}):1}
		done
		
	echo $PASSWORD
}

PASS=$(pwdgen)

echo $BASENAME

mysql -e "CREATE DATABASE $BASENAME"
mysql -e "CREATE USER 'u_$BASENAME'@'localhost';"
mysql -e "GRANT ALL ON $BASENAME.* to 'u_$BASENAME'@'localhost';"
mysql -e "ALTER USER 'u_$BASENAME'@'localhost' IDENTIFIED WITH mysql_native_password BY '$PASS';"
echo u_$BASENAME $PASS >> create_base.log