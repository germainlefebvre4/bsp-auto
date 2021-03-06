#!/bin/bash

date=`date "+%F %T"`
dirname=$(dirname `readlink -f $0`)

header="date"
content=""
voitures=()
voitures[0]="RENAULT MEGANE*"
voitures[1]="BMW SERIE 2 ACTIVE TOURER*"
voitures[2]="RENAULT KANGOO*"
voitures[3]="PEUGEOT 3008*"
voitures[4]="VW TOURAN*"
current_price=198

URL='https://www.bsp-auto.com/fr/list.asp?pays=10&ag_depart=2715&date_a=10/05/2020&heure_a=14:00&ag_retour=2715&date_d=20/05/2020&heure_d=14:00&age=25&chkage=1'

curl -s -o $dirname/bsp-auto.curl "$URL"

# Set header
for i in ${!voitures[@]} ; do
  header="$header,${voitures[$i]}"
done

# Set content
for i in ${!voitures[@]} ; do
  prix=`cat $dirname/bsp-auto.curl | grep -A1 -i -a "class=tit_modele>${voitures[$i]}" | head -2 | tail -1 | grep -o -P "class=tarif>\K([0-9]*)"`
  content="$content,$prix"
done

# Add colummn current if set
if [ "$current_price" != "" ] ; then
  header="$header,Current"
  content="$content,$current_price"
fi

# Print intermediate result
echo "$date$content" | tee -a $dirname/bsp-auto.result

# Print header and content in final file
echo $header > $dirname/bsp-auto
sort -r $dirname/bsp-auto.result >> $dirname/bsp-auto


# Check if price is better and send email
line_last=(`tail -1 $dirname/bsp-auto.result | cut -d',' -f2- | tr ',' '\n'`)
line_before=(`tail -2 $dirname/bsp-auto.result | head -1| cut -d',' -f2- | tr ',' '\n'`)
for((i=0;i<${#line_last[@]};i++)) ; do
  # Handle new values
  if [ "${line_last[$i]}" != "" ] && [ "${line_before[$i]}" != "" ] ; then
    # Test if value is better than the min
    if [ "${line_last[$i]}" -lt "${current_price}" ] ; then
      flag_email=0
    fi
  fi
done

# Send email when better price found
if [ $flag_email ] ; then
  echo "A better price comes up. Email sent."
  sendmail -t < $dirname/email.template
fi
