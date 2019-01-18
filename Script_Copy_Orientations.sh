#!/bin/bash
#Programme pour copier les orientations MicMac faites 
#sur des données Panchro vers des données de Pan-Sharpen
#Ce script doit être lancé depuis le répertoire Ori-.... issu de l'ajustement par Campari
#nommage panchro ..._P_...
#nommage pan-sharpen ..._PMS_...
#Jules Fleury - SIGéo/CEREGE
#2019

ZEDATE=`date +%Y-%m-%d_%H-%M-%S`
echo "Début du traitement : $ZEDATE"

#1-
#split Pan-sharpen bands
#ceci est réalisé avec otbcli_splitimage.....

#2-
#copie et renommage des orientations ajustées
#pour les orientations initiales
printf "\n***Orientation initiales***\n\n"
for i in UnCor*
do	
        echo "Fichier in : $i"
        fname=$(echo $i| cut -d'.' -f 1)
	fout=`echo "$i" | sed "s/_P_/_PMS_/g"`
	echo "Fichier out : $fout"
        cp $i $fout
done

#3- 
#copie, renommage, et modification 
#pour les orientations ajustées
printf "\n***Orientation ajustées***\n\n"
for i in GB*
do
	echo "Fichier in : $i"
	fname=$(echo $i| cut -d'.' -f 1)
	numfi=$(echo $fname| cut -d'-' -f 4)
	nomim=$(echo $fname| cut -d'-' -f 3)
	nom_1=$(echo $nomim| cut -d'_' -f 1)
	nom_2=$(echo $nomim| cut -d'_' -f 2)
	nom_3=$(echo $nomim| cut -d'_' -f 3)
	nom_4=$(echo $nomim| cut -d'_' -f 4)
	nom_5=$(echo $nomim| cut -d'_' -f 5)
	nom_6=$(echo $nomim| cut -d'_' -f 6)
	printf ' Numero fichier : %s \n Fichier orientation : %s \n Image : %s\n' "$numfi" "$fname" "$nomim"
	nomout=`printf '%s_%s_PMS_%s_%s_%s-%s.TIF.xml' "$nom_1" "$nom_2" "$nom_4" "$nom_5" "$nom_6" "$numfi"`
	fout=`printf 'GB-Orientation-%s' "$nomout"`
	echo "Fichier out : $fout"
	cp $i $fout
	sed -i "s/"$nomim"/"$nomout"/g" $fout
	sed -i "s/_P_/_PMS_/g" $fout
done

#4-
#Lancer MicMac Malt de la facon suivante
#mm3d Malt Ortho "Pattern de toutes les images" "dossier_orientations" DirMEC="dossier de la MEC des panchromatiques" InMNT="Pattern des panchromatiques" DoMEC=1 DoOrtho=1 ImOrtho="Pattern des BAND 1 des trois tri-stéréo" DirOF="dossier des orthophotos du BAND 1" EZA=1
#ou alors si Malt a déjà tourné sur les panchro
#mm3d Malt Ortho "Pattern de toutes les images" "dossier_orientations" DoMEC=0 DoOrtho=1 ImOrtho="Pattern des BAND 1 des trois tri-stéréo" DirOF="dossier des orthophotos du BAND 1"
#exemple : mm3d Malt Ortho "IMG.*.TIF" Ori-RPC-d0-adj DirMEC="MEC-Malt-Zf4" DoMEC=1 ImMNT="IMG.*(00[123]).TIF" ImOrtho="IMG.*_b.*.TIF" DirOF="Ortho_Fusion" DoOrtho=1 ZoomF=4 EZA=1


#5- 
#Rassembler les différents canaux des images pan-sharpen
#otbcli_ConcatenateImages ....









