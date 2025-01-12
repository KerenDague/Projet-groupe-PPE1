#!/usr/bin/env bash
# se lancer depuis la racine du projet
# ./programmes/corpus_ch_itrameur.sh

if [[ $# -ne 2 ]]
then
	echo "Deux arguments attendus: <dossier> <langue>"
	exit
fi

folder=$1       # dumps-text ou contextes
basename=$2     # chinois, français

output_dir="../itrameur"
mkdir -p $output_dir

output_file="$output_dir/$folder-$basename.txt"
echo "<lang=\"$basename\">" > "$output_file"

echo "Traitement des fichiers dans $folder pour $basename..."

for filepath in $(ls $folder/$basename-*.txt)
do
	# filepath == dumps-texts/chinois-1.txt
	# pagename = chinois-1
	pagename=$(basename -s .txt $filepath)

	echo "<page=\"$pagename\">" >> "$output_file"
	echo "<text>" >> "$output_file"
	
	# on récupère les dumps et les contextes respectivement
	content=$(cat $filepath)
	content=$(echo "$content" | sed 's/&/&amp;/g')
	content=$(echo "$content" | sed 's/</&lt;/g')
	content=$(echo "$content" | sed 's/>/&gt;/g')

	echo "$content" >> "$output_file"

	echo "</text>" >> "$output_file"
	echo "</page> §" >> "$output_file"
done

echo "</lang>" >> "$output_file"
