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
mkdir OUTPUT

#export with gdal
strfinal=${strdataset}_$EPSG #string to hold the dataset identifier and the epsg code
echo "exporting CORR with GDAL to CORR_$strfinal.tif"
gdal_translate -a_srs EPSG:$EPSG $lastcor OUTPUT/CORR_$strfinal.tif -co COMPRESS=DEFLATE
echo "exporting AUTOMASK with GDAL to AUTOMASK_$strfinal.tif"
gdal_translate -a_srs EPSG:$EPSG $lastautomask OUTPUT/AUTOMASK_$strfinal.tif -co COMPRESS=DEFLATE
echo "exporting DEM with GDAL to DEM_$strfinal.tif"
gdal_translate -a_srs EPSG:$EPSG $lastDEM OUTPUT/DEM_$strfinal.tif -co COMPRESS=DEFLATE


# Set no correlation zones to NODATA using AUTOMASK
cd OUTPUT
echo "Filtering nodata values with the AUTOMASK, a second filtering with a polygon is sometimes necessary"
gdal_calc.py -A DEM_$strfinal.tif -B AUTOMASK_$strfinal.tif --calc=A*B --NoDataValue=0 --outfile=DEM_$strfinal-cleaned.tif
echo "Compressing final DEM"
gdal_translate DEM_$strfinal-cleaned.tif DEM_$strfinal-clean.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES
rm DEM_$strfinal-cleaned.tif
#Clipping with cutline
echo "Clipping DEM with cutline from Shapefile"
gdalwarp -s_srs EPSG:$EPSG -cutline ClippingFile.shp DEM_$strfinal-clean.tif DEM_$strfinal-C_D.tif -co COMPRESS=DEFLATE -co BIGTIFF=YES -co TILED=YES

#Smoothing with OTB gaussian
echo "Smoothing DEM"
otbcli_Smoothing -in DEM_$strfinal-C_D.tif -type gaussian -type.gaussian.radius 2 -progress 1 -out DEM_gauss.tif
gdal_translate DEM_gauss.tif DEM_$strfinal-C_D_SGauss2.tif -co COMPRESS=DEFLATE -co TILED=YES -co BIGTIFF=YES
rm DEM_gaus.tif

#Hillshading
echo "Hillshading DEM"
gdaldem hillshade DEM_$strfinal-clean.tif SHD_DEM_$strfinal-clean.tif -co COMPRESS=DEFLATE
gdaldem hillshade DEM_$strfinal-C_D_SGauss2.tif SHD_DEM_$strfinal-C_D_SGauss2.tif -co COMPRESS=DEFLATE

echo "  
	******************************************** 
	***               Finished               ***
	***     Results are in OUTPUT folder     ***
	********************************************
	"

# One should then filter the resulting DEM using either Despeckle or Gaussian filters

# For Orthophoto, automatic processing is not done as usually a tile merging must be done before


