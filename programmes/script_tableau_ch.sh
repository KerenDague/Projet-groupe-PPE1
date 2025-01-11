#!/usr/bin/bash

if [ $# -ne 1 ]; then
  echo "$0 demande un argument"
  exit 1
fi

urlfile=$1
num_ligne=1

mkdir -p aspirations/chinois dumps-text/chinois tableaux contextes/chinois concordances/chinois

echo "<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Tableau chinois</title>
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
    <h1>Tableau "课程/过程" en chinois</h1>
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
    <tbody>" > ./tableaux/tableau_ch.html

while read -r line; 
do
    reponse=$(curl -s -L -w "%{content_type}\t%{http_code}" -o ./aspirations/chinois/chinois-$num_ligne.html "$line")
    echo "$line"
    http_code=$(echo "$reponse" | cut -f2)
    encodage=$(echo "$reponse" | egrep -o "charset=\S+" | cut -d "=" -f2 | tail -n1)
    encodage=${encodage:-"UTF-8"}

    if [ "$http_code" != "200" ]; then
        echo "URL invalide ou introuvable：code http = $http_code" >&2
        continue
    fi

    if command -v w3m >/dev/null 2>&1; then
        w3m -dump ./aspirations/chinois/chinois-$num_ligne.html > ./dumps-text/chinois/chinois-$num_ligne.txt
    else
        lynx -assume_charset=UTF-8 -dump -nolist ./aspirations/chinois/chinois-$num_ligne.html > ./dumps-text/chinois/chinois-$num_ligne.txt
    fi

    nb_mots=$(wc -w < ./dumps-text/chinois/chinois-$num_ligne.txt)
    compte=$(grep -o -E "课程|过程" ./dumps-text/chinois/chinois-$num_ligne.txt | wc -l)
    dumplink="<a href='../dumps-text/chinois/chinois-$num_ligne.txt'>dump</a>"
	aspiration="<a href='../aspirations/chinois/chinois-$num_ligne.html'>aspiration</a>"

    # Contexte
    contexte_file="./contextes/chinois/chinois-$num_ligne.txt"
    grep -B2 -A2 -E "课程|过程" ./dumps-text/chinois/chinois-$num_ligne.txt > "$contexte_file"

    # Concordance
    concordance_file="./concordances/chinois/chinois-$num_ligne.html"
    echo "<html><head><meta charset='UTF-8'><title>Concordance</title></head>
    <body><table border='1'><tr><th>Gauche</th><th>Cible</th><th>Droite</th></tr>" > "$concordance_file"
    grep -o -E ".{0,30}(课程|过程).{0,30}" ./dumps-text/chinois/chinois-$num_ligne.txt | \
    sed -E "s/(.*)(课程|过程)(.*)/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/" >> "$concordance_file"
    echo "</table></body></html>" >> "$concordance_file"

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
        <td><a href="../contextes/chinois/chinois-$num_ligne.txt">contexte</a></td>
        <td><a href="../concordances/chinois/chinois-$num_ligne.html">concordance</a></td>
        </tr>" >> ./tableaux/tableau_ch.html

    num_ligne=$(expr $num_ligne + 1)
done < "$urlfile"

echo "</tbody>
</table>
</div>
</body>
</html>" >> ./tableaux/tableau_ch.html
