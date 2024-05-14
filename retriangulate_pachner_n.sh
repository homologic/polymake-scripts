#!/bin/bash


# Usage: ./run-script-sql.sh script query


echo "$(date) $0 $@" >> run-script.log


n=$1
m=$(($n+2))

mkdir -p "researchdata/pachnerlog/"
while true
do
	complex=$(psql -d researchdata_test -c "SELECT signature FROM pachner_$n WHERE pachner_$m = '' " | grep '^ g' | sed 's/ //g'  | head -n 1)
	[ -z "$complex" ] && break
	{ time /usr/local/bin/retriangulate -e -4 -h4 -t12 $complex; } 2> "researchdata/pachnerlog/$complex.log$m" | while read k
	do
		len=$(echo -n "$k" | wc -c)
		if [ "$len" -lt 36 ]
		then
			echo "$len"
			psql -d researchdata_test -c "INSERT INTO smaller_complexes VALUES ('$k', '$complex') ON CONFLICT DO NOTHING;" 
		else
			psql -d researchdata_test -c "UPDATE pachner_$n SET pachner_$m = '$complex' WHERE signature = '$k' AND pachner_$m = '';" >/dev/null 2>&1 
		fi
	done
done
		
for k in researchdata/pachnerlog/*$m
do
	complex=$(echo $k | sed 's,^.*/\([^/]*\)\..*$,\1,g')
	total=$(cat $k | grep "^Considered" | sed 's/[^0-9]//g')
	tri=$(cat $k | grep "^Found" | sed 's/[^0-9]//g')
	psql -d researchdata_test -c "INSERT INTO pachner_$m VALUES ('$complex', $total) ON CONFLICT DO NOTHING;";
done
