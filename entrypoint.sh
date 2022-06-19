#! /usr/bin/env bash

#----------------------------------------------------------------------------------------------------------------------------------------
cat > index-template.html <<EOF

<!DOCTYPE html>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
 <title>Test Results</title>
 <style type="text/css">
  BODY { font-family : monospace, sans-serif;  color: black;}
  P { font-family : monospace, sans-serif; color: black; margin:0px; padding: 0px;}
  A:visited { text-decoration : none; margin : 0px; padding : 0px;}
  A:link    { text-decoration : none; margin : 0px; padding : 0px;}
  A:hover   { text-decoration: underline; background-color : yellow; margin : 0px; padding : 0px;}
  A:active  { margin : 0px; padding : 0px;}
  .VERSION { font-size: small; font-family : arial, sans-serif; }
  .NORM  { color: black;  }
  .FIFO  { color: purple; }
  .CHAR  { color: yellow; }
  .DIR   { color: blue;   }
  .BLOCK { color: yellow; }
  .LINK  { color: aqua;   }
  .SOCK  { color: fuchsia;}
  .EXEC  { color: green;  }
 </style>
</head>
<body>
	<h1>Test Results</h1><p>
	<a href=".">.</a><br>

EOF
#----------------------------------------------------------------------------------------------------------------------------------------
mkdir -p ./${INPUT_RESULTS_HISTORY}

if [[ ${INPUT_REPORT_URL} != '' ]]; then
    AZ_WEBSITE_URL="${INPUT_REPORT_URL}"
fi
#----------------------------------------------------------------------------------------------------------------------------------------
# Install Azcopy

# https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10#use-azcopy-in-a-script
echo "Setup AzCopy.."
mkdir -p tmp
cd tmp
wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
cp ./azcopy /usr/bin/
cd ..

# Check that azcopy command works from container
azcopy --version
#----------------------------------------------------------------------------------------------------------------------------------------
# List Blobs
sh -c "azcopy list 'https://${INPUT_ACCOUNT_NAME}.blob.core.windows.net/${INPUT_CONTAINER}?${INPUT_SAS}'" | grep "INFO:" | sed 's/INFO: //' | while read line; 
    do 
    	FOLDER_NAME="$( cut -d '/' -f 1 <<< "$line" )"; 
	NEW_FOLDER_NAME="$( cut -d ';' -f 1 <<< "$FOLDER_NAME" )";  
	echo "$NEW_FOLDER_NAME" >> folder_file.txt
        sort -u folder_file.txt | grep -v 'index.html' > clean_folder_file.txt
    done;
#----------------------------------------------------------------------------------------------------------------------------------------
# # Delete history    
COUNT=$(cat clean_folder_file.txt | wc -l)
echo "count folders in results-history: ${COUNT}";
echo "keep reports count ${INPUT_KEEP_REPORTS}";
INPUT_KEEP_REPORTS=$((INPUT_KEEP_REPORTS+1));
echo "if ${COUNT} > ${INPUT_KEEP_REPORTS}";
if (( COUNT > INPUT_KEEP_REPORTS )); then
  NUMBER_OF_FOLDERS_TO_DELETE=$((${COUNT}-${INPUT_KEEP_REPORTS}));
  echo "remove old reports";
  echo "number of folders to delete ${NUMBER_OF_FOLDERS_TO_DELETE}";
  cat clean_folder_file.txt | sort -n | head -n ${NUMBER_OF_FOLDERS_TO_DELETE} | while read line;
  	do
		az storage blob delete-batch -s ${INPUT_CONTAINER} --sas-token ${INPUT_SAS} --auth-mode key --account-name ${INPUT_ACCOUNT_NAME} --delete-snapshots include --pattern ${line}/*
	        echo "deleted prefix folder : ${line}";
	done;
fi;
#----------------------------------------------------------------------------------------------------------------------------------------

# List Blobs Post Delete
rm -rf folder_file.txt clean_folder_file.txt
sh -c "azcopy list 'https://${INPUT_ACCOUNT_NAME}.blob.core.windows.net/${INPUT_CONTAINER}?${INPUT_SAS}'" | grep "INFO:" | sed 's/INFO: //' | while read line; 
    do 
    	FOLDER_NAME="$( cut -d '/' -f 1 <<< "$line" )"; 
	NEW_FOLDER_NAME="$( cut -d ';' -f 1 <<< "$FOLDER_NAME" )";  
	echo "$NEW_FOLDER_NAME" >> folder_file.txt
        sort -u folder_file.txt | grep -v 'index.html' > clean_folder_file.txt
    done;
#----------------------------------------------------------------------------------------------------------------------------------------
# Construct Index.html file

cat index-template.html > ./${INPUT_RESULTS_HISTORY}/index.html

echo "├── <a href="./${INPUT_GITHUB_RUN_NUM}/index.html">Latest Test Results - RUN ID: ${INPUT_GITHUB_RUN_NUM}</a><br>" >> ./${INPUT_RESULTS_HISTORY}/index.html;

cat clean_folder_file.txt | grep -v 'index.html' | sort -nr | while read line; do echo "├── <a href="./"${line}"/">RUN ID: "${line}"</a><br>" >> ./${INPUT_RESULTS_HISTORY}/index.html; done

echo "</html>" >> ./${INPUT_RESULTS_HISTORY}/index.html;
cat ./${INPUT_RESULTS_HISTORY}/index.html

echo "copy test-results to ${INPUT_RESULTS_HISTORY}/${INPUT_GITHUB_RUN_NUM}"
cp -R ./${INPUT_TEST_RESULTS}/. ./${INPUT_RESULTS_HISTORY}/${INPUT_GITHUB_RUN_NUM}

#----------------------------------------------------------------------------------------------------------------------------------------

# Azure Blob Upload for the latest results

sh -c "azcopy sync '${INPUT_RESULTS_HISTORY}' 'https://${INPUT_ACCOUNT_NAME}.blob.core.windows.net/${INPUT_CONTAINER}?${INPUT_SAS}' --recursive=true "

