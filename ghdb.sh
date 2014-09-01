#!/bin/bash
#This script scraps Exploit-DB's Google Hacking Database and outputs the
#google dorks in a csv file for use in future recon-ng google hacking module
# 
# <eric.gragsone@erisresearch.org>
#
#WARNING - WARNING - WARNING - WARNING
#Exploit-DB probably doesn't like their site scrapped, so don't do it too often 

USER_AGENT='Diddly_Doo/1.0'

cats=('ErisResearch' 'Footholds' 'Files containing usernames'
  'Sensitive Directories' 'Web Server Detection' 'Vulnerable Files'
  'Vulnerable Servers' 'Error Messages' 'Files containing juicy info'
  'Sensitive Online Shopping Info' 'Network or vulnerable data'
  'Pages containing login portals' 'Various Online Devices'
  'Advisories and Vulnerabilities')
url='http://www.exploit-db.com/google-dorks'
x=''

for i in `seq 1 13`;
do
  if [ "$x" == 'refresh' ]; then
    # so we don't annoy the good people at exploit-db by spidering too often
    wget -r -nH --include /ghdb /google-dorks -U $USER_AGENT -O "${cats[$i]}.txt" -e robots=off $url/$i/
  fi

  cat=${cats[$i]}

  OIFS=$IFS
  IFS=$'\n'
  results=($(cat "${cats[$i]}.txt" | tr '\r\n' ' ' | grep -Po '<h2>Google search:.*?<p class="text">.*?</p>'| sed 's/<br \/>//g' | sed 's/\t//g' | sed 's/  */ /g'))
  for result in ${results[@]};
  do
    if [ "$x" == 'debug' ]; then
      echo $result
      echo -------
    fi

    dork=($(echo $result | tr '\r\n' ' ' | grep -oP '\<a href=.*?>.*?<\/a>' | grep -oP '>.*?<\/a>' | grep -oP '>.*?<' | tr \<\> \"))
    note=($(echo $result | tr '\r\n' ' ' | grep -oP '<p class="text">.*?</p>' | grep -oP '>.*?<' | tr \<\> \"))

    if [ "$x" == 'debug' ]; then
      echo "$cat", $dork, $note
      echo =======
    fi

    echo "$cat", $dork, $note >> ghdb.csv
  done

  IFS=$OIFS
done
