#!/bin/bash

#	Script : 
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

#input string for defining the dataset identifier
#e.g. for Pleiades "TPP241698"
echo "
	Input text for the dataset identifier :
 	e.g.	for Pleiades TPP241698
	To exit : 0
	"
read strdataset

#init variables
shp="./Decoup-FCG.shp" #Shapefile for clipping 
#!!! be carefull to the location of the shapefile, it must be in the MEC-Malt folder
outdir="OUTPUT" #Output directory
strfinal=${strdataset}_$EPSG #string to hold the dataset identifier and the epsg code

#Post Processing ######################################
echo "  
	******************************************** 
	***        Post-processing               ***
	********************************************
	"
#get the last file names
finalDEMs=($(ls Z_Num*_DeZoom*_STD-MALT.tif))
finalcors=($(ls Correl_STD-MALT_Num*.tif))
finalautomask=($(ls AutoMask_STD-MALT_Num*.tif))
DEMind=$((${#finalDEMs[@]}-1))
corind=$((${#finalcors[@]}-1))
autoind=$((${#finalautomas[@]}-1))
lastDEM=${finalDEMs[DEMind]}
lastcor=${finalcors[corind]}
lastautomask=${finalautomask[autoind]}
laststr="${lastDEM%.*}"
corrstr="${lastcor%.*}"
automstr="${lastautomask%.*}"
echo "DEM : lastDEM=$lastDEM; laststr=$laststr"
echo "CORRELATION : lastcor=$lastcor; corrstr=$corrstr"
echo "AUTOMASK : lastautomask=$lastautomask; automstr=$automstr"

#copy tfw
cp $laststr.tfw $corrstr.tfw
cp $laststr.tfw $automstr.tfw
mkdir $outdir

#export with gdal
echo "exporting CORR with GDAL to CORR_$strfinal.tif"
gdal_translate -a_srs EPSG:$EPSG $lastcor $outdir/CORR_$strfinal.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES
echo "exporting AUTOMASK with GDAL to AUTOMASK_$strfinal.tif"
gdal_translate -a_srs EPSG:$EPSG $lastautomask $outdir/AUTOMASK_$strfinal.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES
echo "exporting DEM with GDAL to DEM_$strfinal.tif"
gdal_translate -a_srs EPSG:$EPSG $lastDEM $outdir/DEM_$strfinal.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES


# Set no correlation zones to NODATA using AUTOMASK
cd $outdir
echo "Filtering nodata values with the AUTOMASK, a second filtering with a polygon is sometimes necessary"
#first set 0 value in Automask to nodata
gdal_translate -a_nodata 0 AUTOMASK_$strfinal.tif AUTOMASK_$strfinal-nodata.tif
#then set nodata values in automask to nodata values in dem
gdal_calc.py -A DEM_$strfinal.tif -B AUTOMASK_$strfinal-nodata.tif --calc=A*B --outfile=DEM_$strfinal-cleaned.tif
echo "Compressing final DEM"
gdal_translate DEM_$strfinal-cleaned.tif DEM_$strfinal-C.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES
rm DEM_$strfinal-cleaned.tif
#Clipping with cutline 
#echo "Clipping DEM with cutline from Shapefile"
#gdalwarp -s_srs EPSG:$EPSG -cutline ../$shp DEM_$strfinal-C.tif DEM_$strfinal-C_D.tif -co COMPRESS=DEFLATE -co BIGTIFF=YES -co TILED=YES

#Smoothing with OTB gaussian
#!!!!!!!!! There is a problem of border effect as nodata values are taken into account!!!!!!!!!!
#!!!!!!!!! prefer not to use this way of filtering => a better way is to use MDENOISE
echo "Smoothing DEM"
otbcli_Smoothing -in DEM_$strfinal-C.tif -type gaussian -type.gaussian.radius 2 -progress 1 -out DEM_gauss.tif
gdal_calc.py -A DEM_gauss.tif -B AUTOMASK_$strfinal-nodata.tif --calc=A*B --outfile=DEM_gauss2.tif
gdal_translate DEM_gauss2.tif DEM_$strfinal-C_F.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES
#rm DEM_gauss*.tif 

#Hillshading
echo "Hillshading DEM"
gdaldem hillshade DEM_$strfinal-C.tif SHD_DEM_$strfinal-C.tif -co COMPRESS=DEFLATE
gdaldem hillshade DEM_$strfinal-C_F.tif SHD_DEM_$strfinal-C_F.tif -co COMPRESS=DEFLATE

echo "  
	******************************************** 
	***               Finished               ***
	***     Results are in $outdir folder     ***
	********************************************
	"

# One should then filter the resulting DEM using either Despeckle or Gaussian filters


