#!/bin/bash

echo "Welcome to Nessus Policy Analyzer"
echo
echo

echo "checking prerequisities"
 #checking xmlstarlet
if  [ `which xmlstarlet|wc -l` -eq 0 ]; then
	echo "xmlstarlet package is not installed, Kindly install it first;"
	exit 0;
else
	echo "xmlstarlet check ..... Passed"
fi

# checking arguments
if [ -z $1 ]; then
	echo "specify the filename/path"
	exit 0;
else
	echo "file specified $1"
fi
echo
echo
echo
echo
echo "Analysis Started ......."
file=$1

C=`xmlstarlet sel -t -c "count(//FamilyItem)" $1` #counting the Familys in the policy


#listing the diabled plugins family
echo "This is the disabled plugins"	
for (( i=1; i<=$C; i++ )) ; do 
	#concatenting the FamilyName against the Status... filtering the XML/Nessus first by FamilyItem
	D=`xmlstarlet sel  -t -c "//FamilyItem[$i]" $file | xmlstarlet sel -t -m "//FamilyName"   -v . -o '| '; xmlstarlet sel  -t -c "//FamilyItem[$i]" $file | xmlstarlet sel -t -v '//Status' -n;`
	echo "$D"|grep -i disable|cut -d"|" -f 1
done



echo 
echo 



#listing the mixed plugins family
echo "This is the partial enabled plugins"	
echo "PluginID,Severity (based on CVSS),Family,Filename,Vulnerability">$file.csv
for (( i=1; i<=$C; i++ )) ; do 
	#concatenting the FamilyName against the Status... filtering the XML/Nessus first by FamilyItem
	M=`xmlstarlet sel  -t -c "//FamilyItem[$i]" $file | xmlstarlet sel -t -m "//FamilyName"   -v . -o '| '; xmlstarlet sel  -t -c "//FamilyItem[$i]" $file | xmlstarlet sel -t -v '//Status' -n;`
	M1=`echo "$M"|grep -i mixed|cut -d"|" -f 1` #echo the mixed Family
	if [ `echo "$M"|grep -i mixed|cut -d"|" -f 1|wc -l` -gt 0 ]; then #if there is Family mixed
		echo $M1;
		for j in $(ls /opt/nessus/lib/nessus/plugins); do 
			#loop on each plugin installed in the machine and check if it is related to the mixed family
			if [ `egrep -i "family" /opt/nessus/lib/nessus/plugins/$j|egrep -i "\"$M1\""|wc -l` -gt 0 ]; then 
				PID=`cat /opt/nessus/lib/nessus/plugins/$j|grep script_id|cut -d")" -f1|cut -d"(" -f2`;
				PN=`cat /opt/nessus/lib/nessus/plugins/$j|grep script_name|cut -d"\"" -f2`;
				# check if this plugin ID is listed in the .nessus file if not listed then it is disabled and need to check it's severity from the internet nessus site or tenable site
				if [ `grep -i $PID $file|wc -l` -eq 0 ]; then
					wget  "https://www.tenable.com/plugins/index.php?view=single&id=$PID" -O tmp
					sleep 5
					SV=`cat tmp|grep -i "/ CVSS"|cut -d"/" -f1|cut -d" " -f1`
					echo $SV
					echo "$PID , $SV , $M1 , $j , $PN">>"$file.csv"
				fi
			fi; 
		done
	fi	

done