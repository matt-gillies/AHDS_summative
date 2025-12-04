test = $1

#List of ID's
if [ $test = "false" ]; then 
    pmids=$(xmllint --xpath "//Id/text()" ../data/raw/IDs/IDs.xml | tr ' ' '\n')
 elif [ $test = "true" ]; then 
     pmids=$(xmllint --xpath "//Id/text()" ../data/raw/IDs/IDs.xml | tr ' ' '\n' | head -n 20)
fi 
#Download from PubMed using ID list
for pmid in $pmids; do
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" > ../data/raw/Articles/article-data-$pmid.xml
sleep 0.5
done

#Remove invalid xml files
for article in ../data/raw/Articles/*.xml; do
    if ! xmlstarlet val "$article" >/dev/null 2>&1; then
    rm -f "$article"
    fi
done



