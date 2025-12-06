
batch=$1


#Download from PubMed using ID list
#https://unix.stackexchange.com/questions/243134/curl-download-multiple-files-with-brace-syntax

pmids=$(tr '\n' ',' < "$batch" | sed 's/,$//')


curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmids}" > ../data/raw/Articles/artbatches/article-$(basename $batch).xml


#Count number of articles https://stackoverflow.com/questions/35669280/how-can-i-count-the-number-of-elements-in-an-xml-document-using-xmlstarlet-in-ba

article_count=$(xmlstarlet sel --nonet --nocatalog -t -v "count(//PubmedArticle)" \
  "../data/raw/Articles/artbatches/article-$(basename $batch).xml" 2>/dev/null)

for i in $(seq 1 $article_count); do
    pmid=$(xmlstarlet sel --nonet --nocatalog -t -v "(//PubmedArticle)[$i]//PMID" \
      "../data/raw/Articles/artbatches/article-$(basename $batch).xml" 2>/dev/null)

    xmlstarlet sel --nonet --nocatalog -t -c "(//PubmedArticle)[$i]" \
      "../data/raw/Articles/artbatches/article-$(basename $batch).xml" \
      2>/dev/null > "../data/raw/Articles/individual/article-data-$pmid.xml"
done

sleep 0.5



