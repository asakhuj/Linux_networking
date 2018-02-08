#!/bin/bash


echo "Hello User \n"

echo "Please enter the threshold for CPU usage"

read cpu_thre                                                #takes CPU threshold as input
#cpu_thre=1
threshold=100
echo "You have entered threshold as = $cpu_thre"

echo "Please enter Time slice"

read Time_slice                                              #Takes time slice as an input
#Time_slice=2
high_alert="very HIGH CPU"
alert="HIGH CPU"
printf "we are running monitoring now. Please enter 'Q' to come out\n"
>alertfile.csv
>CPUload.csv
echo Timestamp, One_min_CPUload, 5_min_CPUload, 15_min_CPUload >> CPUload.csv
echo Timestamp, CPU_load, Alert_message >> alertfile.csv
counter=0                                       		#counter to keep track of time
time_limit=3600							#clear the files after 1 hour
while true; do
		
	upt=$(uptime)                    			 #storing uptime value into variable upt
	echo $upt
	#echo $upt >> CPUload.csv		 		 #Write the cpu load into the file
	load_av=$(echo $upt | sed -n -e 's/^.*average: //p')
	temp=($load_av) 		  
	one_min_av=${temp[0]}					  #To get load average for 1 minute
	five_min_av=${temp[1]}					  #To get load average for 5 minutes
	fifteen_min_av=${temp[2]}
	one_min_av="${one_min_av%%,*}"
	five_min_av="${five_min_av%%,*}"
	timestamp="${upt%%u*}"
	echo $timestamp, $one_min_av, $five_min_av, $fifteen_min_av >> CPUload.csv
	if [ 1 -eq "$(echo "${cpu_thre} < ${one_min_av}" | bc)" ]; then
	#timestamp="${upt%%u*}"
	echo $timestamp, $one_min_av, $alert >> alertfile.csv			#Make an entry if CPU load is critical
	fi
	if [ 1 -eq "$(echo "${cpu_thre} < ${five_min_av}" | bc)" ]; then	
	#timestamp="${upt%%u*}"  
        echo $timestamp, $five_min_av, $high_alert >> alertfile.csv 		#Make an entry if CPU load is critical
	fi
	sleep $Time_slice							#Wait till next time slice
	read -t 0.25 -N 1 input
	if [[ $input == 'q' ]] || [[ $input == 'Q' ]]; then	 		#Look for user input to quit
	break
	fi
	counter=$((counter+Time_slice))
	if [ 1 -eq "$(echo "${counter} > ${time_limit}" | bc)" ]; then
	>CPUload.csv								#Clear file after 1 hour
	>alertfile.csv
	counter=0
	fi
	

done





