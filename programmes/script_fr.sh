#!/usr/bin/bash

if [ $# -ne 1 ]
then
  echo "$0 comprend 1 argument, nom/chemin de fichier"
  exit 1
fi

urlfile=$1
num_ligne=1

echo "<html>
<head>
	<meta charset='UTF-8'>
</head>
<body>
	<table>
		<thead>
			<tr>
			<th>ID</th>
			<th>URLS </th>
			<th>Encodage</th>
			<th>Nombre de mots</th>
			<th>Occurences</th>
			<th>Aspirations</th>
			<th>Dumps</th>
			</tr>
		</thead>
<tbody>" > ./tableaux/tableau_fr.html

while read -r line
do
	reponse=$(curl -s -L -w  "%{content_type}\t%{http_code}" -o ./aspirations/français-$num_ligne.html $line)
	echo $line
        http_code=$(echo "$reponse" | cut -f2)
        content_type=$(echo "$reponse" | cut -f1)
        encodage=$(echo "$content_type" | egrep -o "charset=\S+" | cut -d "=" -f2 | tail -n1)
        encodage=${encodage:-"N/A"}

 	if [ $http_code != "200" ] ;
        then
        echo "URL invalide ou introuvable : code http = $http_code" >&2
        nb_mots="/"
        encodage="/"
        content_type="/"
        fi

	nb_mots=$(lynx "$line" -dump -nolist | wc -w)
	compte=$(egrep -i -o "\b(C|c)ourse(s)?\b" ./dumps-text/français-$num_ligne.txt | wc -l)
	dump=$(lynx  -dump -nolist ./aspirations/français-$num_ligne.html > ./dumps-text/français-$num_ligne.txt)
	dumplink=$(echo "<a href='../dumps-text/français-$num_ligne.txt'>dump</a>")
	aspiration=$(echo "<a href='../aspirations/français-$num_ligne.html'>aspiration</a>")

	echo -e "
		<tr>
		<td>$num_ligne</td>
		<td><a class=\"has-text-primary\" href=\"$line\">$line</a></td>
		<td>$encodage</td>
		<td>$nb_mots</td>
		<td>$compte</td>
		<td>$aspiration</td>
		<td>$dumplink</td>
		</tr>" >> ./tableaux/tableau_fr.html
	num_ligne=$(expr $num_ligne + 1)

done < $urlfile

echo "</tbody>
</table>
</body>
</html>" >> ./tableaux/tableau_fr.html

