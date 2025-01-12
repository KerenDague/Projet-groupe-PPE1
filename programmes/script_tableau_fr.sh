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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Tableau français</title>
    <style>
        body {
            background-color: #ffffff;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }

        h1 {
            text-align: center;
            font-weight: bold;
            font-size: 32px;
            margin-bottom: 20px;
        }

        table {
            width: 90%;
            margin: 0 auto;
            border-collapse: collapse;
            background-color: #ffffff;
        }

        th {
            background-color: #d4e4c4;
            font-weight: bold;
            padding: 10px;
            border: 1px solid #ccc;
        }

        td {
            padding: 10px;
            text-align: center;
            border: 1px solid #ccc;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:nth-child(odd) {
            background-color: #ffffff;
        }

        tr:hover {
            background-color: #cce5cc;
        }
    </style>
</head>
<body>
    <h1>Tableau du mot Course en français</h1>
    <table>
        <thead>
            <tr>
            <th>ID</th>
            <th>URLS</th>
            <th>HTTP Code</th>
            <th>Encodage</th>
            <th>Nombre de mots</th>
            <th>Occurences</th>
            <th>Dumps</th>
            <th>Aspirations</th>
            <th>Contexte</th>
            <th>Concordance</th>
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
    contexte_ok=$(grep -B2 -A2 -E "\b(C|c)ourse(s)?\b" ./dumps-text/français-$num_ligne.txt > ./contextes/français-$num_ligne.txt)
    contexte=$(echo "<a href='../contextes/français-$num_ligne.txt'>contexte</a>")

    concordance_html=$(echo "<html><head><meta charset='UTF-8'><title>Concordance</title></head>
    <body><table border='1'><tr><th>Gauche</th><th>Cible</th><th>Droite</th></tr>" > ./concordances/français-$num_ligne.html)
    concordance_d=$(grep -o -E ".{0,60}((C|c)ourse(s)?).{0,60}" ./dumps-text/français-$num_ligne.txt | \
    sed -E "s/(.*)((C|c)ourse(s)?)(.*)/<tr><td>\1<\/td><td>\2<\/td><td>\5<\/td><\/tr>/" >> ./concordances/français-$num_ligne.html)
    concordance_f=$(echo "</table></body></html>" >> ./concordances/français-$num_ligne.html)
    concordance=$(echo "<a href='../concordances/français-$num_ligne.html'>concordance</a>")

	echo -e "
		<tr>
		<td>$num_ligne</td>
		<td><a href=\"$line\">$line</a></td>
		<td>$http_code</td>
		<td>$encodage</td>
		<td>$nb_mots</td>
		<td>$compte</td>
		<td>$dumplink</td>
		<td>$aspiration</td>
		<td>$contexte</td>
        <td>$concordance</td>
		</tr>" >> ./tableaux/tableau_fr.html

	num_ligne=$(expr $num_ligne + 1)

done < $urlfile

echo "</tbody>
</table>
</div>
</body>
</html>" >> ./tableaux/tableau_fr.html

