# GCS-Text-File-Encoder(Shell-Script)
Encode Text Files to UTF-8 from Google Cloud Storage to Google Bigquery

Sometimes "-E" command doesn't actually encode text files to UTF-8 so we have to use "iconv" instead

Process Flow : CP data from GCS to VM then convert in VM and then load to table in Bigquery (or you can cp back to GCS)
