#!/bin/bash

#	Script : for Tiles fusion with otbcli_TileFusion
#
#	Workflow to postprocess MICMAC dataset
#
# 	Jules Fleury, SIGEO/CEREGE
#	05/2020


# Starting message
echo "
	******************************************** 
	***                                      ***
	***                                      ***
	***        PostProcessing workflow       ***
	***        for MicMac dataset            ***
	***                                      ***
	***                                      ***
	********************************************
	"

#init variables
preftile="Z_Num9_DeZoom1_STD-MALT"
prefim="${preftile}_Tile" #prefix for image name                                                                                                                                           
prefout="${pretile}_OTB_Fusion" #prefix for output name

#check tiles exist
if  [ ! -f "${prefim}_0_0.tif" ]
then
	echo "
	No tile to process
	Exit
	"
	exit 1
fi

#Post Processing ######################################
echo "  
	******************************************** 
	***        Post-processing               ***
	********************************************
	"
#get the last file names
c_index=0 #col index
r_index=0 #row index
for filename in ${prefim}_*.tif; do
	base=${filename%.*}
	echo "File $base"
	sub_row="$(echo $base | cut -d'_' -f 6)"
	sub_col="$(echo $base | cut -d'_' -f 7)"
	if (( "$sub_row" > "$r_index" ))
	then
		r_index=$sub_row
	fi
	if (( "$sub_col" > "$c_index" ))
	then
		c_index=$sub_col
	fi
done
rn=$(($r_index+1)) #number of rows
cn=$(($c_index+1)) #number of cols
echo "last row index $r_index; number of rows $rn"
echo "last col index $c_index; number of cols $cn"

#otb_TileFusion 

ci=0
ri=0
if (( "$cn" == 1 )) && (( "$rn" == 2 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif (( "$cn" == 1 )) && (( "$rn" == 3 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_${ci}_$(($ri+2)).tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif (( "$cn" == 2 )) && (( "$rn" == 1 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif (( "$cn" == 3 )) && (( "$rn" == 1 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_$(($ci+2))_${ri}.tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif [ "$cn" == 2 ] && [ "$rn" == 2 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif [ "$cn" == 2 ] && [ "$rn" == 3 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif ${prefim}_${ci}_$(($ri+2)).tif ${prefim}_$(($ci+1))_$(($ri+2)).tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif [ "$cn" == 3 ] && [ "$rn" == 2 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_$(($ci+2))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif ${prefim}_$(($ci+2))_$(($ri+1)).tif -cols $cn -rows $rn -out ${prefout}.tif uint16
elif [ "$cn" == 3 ] && [ "$rn" == 3 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_$(($ci+2))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif ${prefim}_$(($ci+2))_$(($ri+1)).tif ${prefim}_${ci}_$(($ri+2)).tif ${prefim}_$(($ci+1))_$(($ri+2)).tif ${prefim}_$(($ci+2))_$(($ri+2)).tif -cols $cn -rows $rn -out ${prefout}.tif uint16
else
	echo "Two many tiles for this script, make this tilefusion manually"
	exit 1
fi

#copy tfw
cp ${preftile}.tfw ${prefout}.tfw


echo "  
	******************************************** 
	***               Finished               ***
	***     Result is ${prefout}_Fusion     ***
	********************************************
	"




