#!/bin/bash

#	Script : PostProcess_MicMac.sh
#
#	Workflow to postprocess MICMAC dataset
#
# 	Jules Fleury, SIGEO/CEREGE
#	08/2018


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

#check tiles exist
if  [ ! -f "Orthophotomosaic_Tile_0_0.tif" ]
then
	echo "
	No tile to process
	Exit
	"
	exit 1
fi

#input parameter EPSG
echo "
	Input spatial reference EPSG code :
 	e.g.	4326 : WGS84 
		2154 : RGF93-Lambert93
		32632: WGS84-UTM32N

	To exit : 0
	"
read EPSG

if ! [[ "$EPSG" =~ ^[0-9]+$ ]] 
then
	echo "Sorry integers only" 
	>&1 && exit 1
elif [[ $EPSG -eq 0 ]] 
then
	echo "Check EPSG code and try again"
	exit 1
fi

#init variables
shp="./Decoup-FCG.shp" #Shapefile for clipping 
outdir="OUTPUT1" #Output directory
prefim="Orthophotomosaic_Tile" #prefix for image name
prefout="Orthophotomosaic_OTB_Fusion" #prefix for output name

#Post Processing ######################################
echo "  
	******************************************** 
	***        Post-processing               ***
	********************************************
	"
#get the last file names
c_index=0 #col index
r_index=0 #row index
for filename in Orthophotomosaic_Tile_*.tif; do
	sub_row=${filename:24:1} #substring for row
	sub_col=${filename:22:1} #substring for col
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
mkdir $outdir

ci=0
ri=0
if (( "$cn" == 1 )) && (( "$rn" == 2 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif (( "$cn" == 1 )) && (( "$rn" == 3 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_${ci}_$(($ri+2)).tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif (( "$cn" == 2 )) && (( "$rn" == 1 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif (( "$cn" == 3 )) && (( "$rn" == 1 ))
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_$(($ci+2))_${ri}.tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif [ "$cn" == 2 ] && [ "$rn" == 2 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif [ "$cn" == 2 ] && [ "$rn" == 3 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif ${prefim}_${ci}_$(($ri+2)).tif ${prefim}_$(($ci+1))_$(($ri+2)).tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif [ "$cn" == 3 ] && [ "$rn" == 2 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_$(($ci+2))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif ${prefim}_$(($ci+2))_$(($ri+1)).tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
elif [ "$cn" == 3 ] && [ "$rn" == 3 ]
then
	otbcli_TileFusion -il ${prefim}_${ci}_${ri}.tif ${prefim}_$(($ci+1))_${ri}.tif ${prefim}_$(($ci+2))_${ri}.tif ${prefim}_${ci}_$(($ri+1)).tif ${prefim}_$(($ci+1))_$(($ri+1)).tif ${prefim}_$(($ci+2))_$(($ri+1)).tif ${prefim}_${ci}_$(($ri+2)).tif ${prefim}_$(($ci+1))_$(($ri+2)).tif ${prefim}_$(($ci+2))_$(($ri+2)).tif -cols $cn -rows $rn -out $outdir/${prefout}.tif uint16
else
	echo "Two many tiles for this script, make this tilefusion manually"
	exit 1
fi

#copy tfw
cp Orthophotomosaic.tfw $outdir/Orthophotomosaic_OTB_Fusion.tfw


#gdal_warp without cutline
#gdalwarp -s_srs EPSG:$EPSG -srcnodata 0 Orthophotomosaic_OTB_Fusion.tif Orthophotomosaic_OTB_Fusion_Clip.tif -co COMPRESS=DEFLATE -co BIGTIFF=YES -co TILED=YES
#gdal_warp with cutline
gdalwarp -s_srs EPSG:$EPSG -srcnodata 0 -cutline $shp $outdir/Orthophotomosaic_OTB_Fusion.tif $outdir/Orthophotomosaic_OTB_Fusion_Clip.tif -co COMPRESS=DEFLATE -co BIGTIFF=YES -co TILED=YES

#rm first tiled file
if [ -f "$outdir/Orthophotomosaic_OTB_Fusion_Clip.tif" ]
then
	rm $outdir/Orthophotomosaic_OTB_Fusion.*
fi



echo "  
	******************************************** 
	***               Finished               ***
	***     Results are in $outdir folder     ***
	********************************************
	"




