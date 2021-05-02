#!/bin/bash
echo "Declare Variables"
BIGQUERY_PROJECT=Project_TEST
PATH_ARI=gs://SAP_TextFile/ARI19 #Path Before Endode in GCS
PATH_ARI_UTF_8=gs://SAP_TextFile/ARI19/UTF-8 #Path After Encode to UTF-8 in GCS


DATASET=DATASET_TEST
SCHEMA_FOLDER=schema
DIR_SCHEMA_FOLDER=gs://SAP_TextFile/Schema #Schema Folder
ARI_tables=(119 242 333) #Suffix Pattern in SAP file lists
ARI_tables_list=( $(gsutil ls -d gs://SAP_TextFile/ARI19/*.txt) ) #Get All files that contain Suffix
mkdir $SCHEMA_FOLDER
gsutil -m cp $DIR_SCHEMA_FOLDER/schema*.json $SCHEMA_FOLDER

echo "Encoding SAP ARI Tables"
mkdir old_encoding #Create Folder for Text Files in VM
mkdir utf-8 #Create Folder for Text Files (UTF-8) in VM

#Build a loop to Encode all text files to UTF-8
for i in "${ARI_tables_list[@]}" 
do
    k=${i:55:-4}
    gsutil cp $PATH_ARI/$k.txt ./old_encoding/
    iconv -f "TIS-620" -t "UTF-8" ./old_encoding/$k.txt -o ./utf-8/$k.txt
    gsutil cp ./utf-8/$k.txt $PATH_ARI_UTF_8/
done

echo "Loading SAP ARI tables..."

for i in "${ARI_tables[@]}" 
do
    bq --nosync load -E UTF-8 -F '\t' --replace --source_format=CSV --max_bad_records=0 --project_id=$BIGQUERY_PROJECT --skip_leading_rows=1 $BIGQUERY_PROJECT:$DATASET.DIGITIZE_PAYMENT_SAP_$i $PATH_ARI_UTF_8/ARI19$i*.txt ./$SCHEMA_FOLDER/schema-ARI.json
    echo "table SAP_"$i "is done"
    
done


echo "Load To Table Passed"

rm -rf $SCHEMA_FOLDER
rm -rf old_encoding
rm -rf utf-8