test=$1
url=$2



#Download article ID list
curl -s "$url" > ../data/raw/PMIDs/IDs.xml





#List of ID's
if [ "$test" = "False" ]; then 
    xmllint --xpath "//Id/text()" ../data/raw/PMIDs/IDs.xml | tr ' ' '\n'> "../data/raw/PMIDs/ID_list.txt"
 elif [ "$test" = "True" ]; then 
    xmllint --xpath "//Id/text()" ../data/raw/PMIDs/IDs.xml | tr ' ' '\n' | head -n 20  > "../data/raw/PMIDs/ID_list.txt"
fi 

mkdir -p ../data/raw/PMIDs/ID_batches

split -l 50 "../data/raw/PMIDs/ID_list.txt" "../data/raw/PMIDs/ID_batches/batch_"

