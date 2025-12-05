test=$1



#Download article ID list
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22gaming+disorder%22+OR+%22smartphone+addiction%22+OR+%22internet+addiction%22+OR+%22social+media+addiction%22&retmax=10000" > ../data/raw/PMIDs/IDs.xml





#List of ID's
if [ "$test" = "false" ]; then 
    xmllint --xpath "//Id/text()" ../data/raw/PMIDs/IDs.xml | tr ' ' '\n'> "../data/raw/PMIDs/ID_list.txt"
 elif [ "$test" = "true" ]; then 
    xmllint --xpath "//Id/text()" ../data/raw/PMIDs/IDs.xml | tr ' ' '\n' | head -n 20  > "../data/raw/PMIDs/ID_list.txt"
fi 

mkdir -p ../data/raw/PMIDs/ID_batches

split -l 50 "../data/raw/PMIDs/ID_list.txt" "../data/raw/PMIDs/ID_batches/batch_"

