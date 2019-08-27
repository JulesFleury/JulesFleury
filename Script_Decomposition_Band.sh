#!/bin/bash
#Programme pour décomposer (dupliquer) les orientations MicMac faites 
#sur des données Panchro vers les canaux individuels d'une donnée de Pan-Sharpen
#Attention certaines étapes ne sont pas implémentées par le script (indiquées en commentaires) et doivent être lancées séparemment
#Ce script doit être lancé depuis le répertoire Ori-.... issu de l'ajustement par Campari
#nommage panchro ..._P_...
#nommage pan-sharpen ..._PMS_...
#Jules Fleury - SIGéo/CEREGE
#2019

ZEDATE=`date +%Y-%m-%d_%H-%M-%S`
echo "Début du traitement : $ZEDATE"

#0
#Pan-sharpen : avec votre outil favori, par ex. otbcli_BundletoPerfectSensor (parfait pour un bundle Pléiades)

#1-
#split Pan-sharpen bands (séparation des bandes d'une image MS vers des images individuelles)
#ceci est réalisé avec otbcli_splitimage.....

#2-
#copie et renommage des orientations ajustées
#pour les orientations initiales
printf "\n***Orientation initiales***\n\n"
for i in UnCor*
do	
	fname=$(echo $i| cut -d'.' -f 1) #nom fichier sans extension
	printf 'Fichier %s\n' "$fname"
	n=0
	for run in {1..4}
	do
		fname2=`printf '%s_b_%s.XML.xml' "$fname" "$n"` #nom fichier avec suffixe pour numero bande
		fout=`echo "$fname2" | sed "s/_P_/_PMS_/g"`
		printf 'Creation fichier avec suffixe : %s\n' "$fout"		
		cp $i $fout 
		n=$((n+1))
	done
done

#3- 
#copie, renommage, et modification 
#pour les orientations ajustées
printf "\n***Orientation ajustées***\n\n"
for i in GB*
do
	echo "Fichier $i"
	fname=$(echo $i| cut -d'.' -f 1)
	numfi=$(echo $fname| cut -d'-' -f 4)
	nomim=$(echo $fname| cut -d'-' -f 3)
	printf ' Numero fichier : %s \n Fichier orientation : %s \n Image : %s\n' "$numfi" "$fname" "$nomim"
	n=0
	for run in {1..4}
	do
		#echo $n
		fout=`printf '%s_b_%s.TIF.xml' "$fname" "$n"`
		fout=`echo "$fout" | sed "s/_P_/_PMS_/g"`
		printf 'Creation fichier avec suffixe : %s\n' "$fout"	
		cp $i $fout
		sed -i "s/"$numfi".XML/"$numfi"_b_"$n".XML/g" $fout
		sed -i "s/"$numfi".TIF/"$numfi"_b_"$n".TIF/g" $fout
		sed -i 's/_P_/_PMS_/g' $fout
		n=$((n+1))
	done
done

#4-
#Lancer MicMac Malt de la facon suivante si Malt n'a pas déjà tourné
#mm3d Malt Ortho "Pattern de toutes les images" "dossier_orientations" DirMEC="dossier M#exemple : mm3d Malt Ortho "IMG.*.TIF" Ori-RPC-d0-adj DirMEC="MEC-Malt-Zf4" DoMEC=1 ImMNT="IMG.*(00[123]).TIF" ImOrtho="IMG.*_b.*.TIF" DirOF="Ortho_Fusion" DoOrtho=1 ZoomF=4 EZA=1EC des panchromatiques" ImMNT="Pattern des panchromatiques" DoMEC=1 DoOrtho=1 ImOrtho="Pattern des MS Pan-sharpen" DirOF="dossier des orthophotos" EZA=1
#exemple : mm3d Malt Ortho "IMG.*.TIF" Ori-RPC-d0-adj DirMEC="MEC-Malt_final" DoMEC=1 ImMNT="IMG.*(00[123]).TIF" ImOrtho="IMG.*_b.*.TIF" DirOF="Ortho_Fusion" DoOrtho=1 EZA=1
#ou alors si Malt a déjà tourné sur les panchros
#mm3d Malt Ortho "Pattern de toutes les images" "dossier_orientations" DoMEC=0 DoOrtho=1 ImOrtho="Pattern des MS Pan-sharpen" DirOF="dossier des orthophotos"



#5- 
#Rassembler les différents canaux des images pan-sharpen
#otbcli_ConcatenateImages ....









