#!/bin/bash

rec=/tmp/line
log=/home/access.log
rep=/tmp/report.txt
lastrecord=$(cat $rec)
X=10
Y=20
code=1
get_firstandlastline()
{
maxline=$(cat $1 | wc -l)
let "start = lastrecord + 1"
}

get_startendtime()
{
starttime=`sed -n "$start{p;q}" $1 | awk '{print$4}' | sed -e 's/\[//g'`
endtime=`sed -n "$maxline{p;q}" $1 | awk '{print$4}' | sed -e 's/\[//g'`
}

grouping_request_ip_address()
{ echo "Report  within range from $starttime and until $endtime" > $rep
  echo "-------------------------------------------------------------------" >> $rep
  echo "Summary of ip addresses" >> $rep
echo "`sed -n ""$start","$maxline"p" $1  | awk '{print$1}' | sort | uniq -c | sort -nr | awk '{if(NR<='$X') print $1,$2}' | sed -e 's/\(^[0-9]\{1,4\}\)/number of occurances: &/g' | sed  -e 's/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)/ip address: &/g'`" >> $rep
}

grouping_respond_ip_address() 
{   
  echo "-------------------------------------------------------------------" >> $rep   
  echo "Summary of requested ip addresses" >> $rep
  echo "`sed -n ""$start","$maxline"p" $1 | awk -F'"' '{if($2!="") print$1}' | awk '{print$1}' | sort | uniq -c | sort -nr | awk '{if(NR<='$Y') print $1" "$2}' | sed -e 's/\(^[0-9]\{1,4\}\)/number of occurances: &/g' | sed  -e 's/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)/ip address: &/g'`" >> $rep 
}


grouping_return_code()
{ 
  echo "--------------------------------------------------------------------" >> $rep
  echo "Summary of returned codes" >> $rep
  echo "`sed -n ""$start","$maxline"p" $1 | awk -F'"' '{print$3}' | awk '{print$1}' | sort | uniq -c | sort -nr | awk '{print "number of occurances: "$1 " code: "$2}'`" >> $rep
}

check_error()
{ code=1 
  local res=`echo "$1" | awk -F'"' '{print$3}' | awk '{print$1}'`

if [ $res -eq 404 ]
then  
code=404
fi
}

print_error() 
{
 echo "----------------------------------------------------" >> $rep 
 echo "Records with errors" >> $rep
 res=`sed -n ""$start","$maxline"p" $1`
 printf %s/n "$res" | while IFS= read -r line  
 do
 check_error "$line"
if [ $code -eq 404 ]
then
echo "$line" >> $rep
fi
done
}

finish()
{
find /tmp -name lock -delete
exit $?
}
 
mail()
{
sudo -s mail -s "Nginx log's report" azinc@yandex.ru < $rep
}

if( set -o noclobber; echo "11" > /tmp/lock) 
then
trap finish INT TERM EXIT KILL
get_firstandlastline "$log" 
get_startendtime "$log"
grouping_request_ip_address "$log" 
grouping_respond_ip_address "$log" 
grouping_return_code "$log"
print_error "$log"
echo "$maxline" > $rec
mail
finish
fi
