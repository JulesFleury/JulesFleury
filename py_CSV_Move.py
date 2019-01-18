# py_CSV_Move.py
# JF - 05/07/2018

# lit un fichier CSV
# dans chaque ligne, la premiere colonne correspond a un nom de fichier
# ce fichier est deplace

# la premiere ligne est une ligne d'entete

import csv
import sys
import os
import shutil

import os.path

csvFile = 'myData.csv'
csvData = csv.reader(open(csvFile), delimiter=',')

#nouveau repertoire pour le deplacement
newpath='storage_files'
cwd = os.getcwd()

rowNum = 0

for row in csvData:
    if rowNum == 0:        
	tags = row
        print('Fields : ', len(tags))
	print(tags[0])

    else: 	
	im = row[0]
	print(im)
	if os.path.isfile(im):
		print('existe : ', im)
		newloc=cwd + '/' + newpath + '/' + im
		if os.path.exists(newpath):
			print('nouvelle loc', newloc)
			shutil.move(im, newloc)
    		else:
			print('Location does not exist. You must create directory : ',newpath)
			exit()
    rowNum +=1

