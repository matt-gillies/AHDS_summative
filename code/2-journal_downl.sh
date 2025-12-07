#!/usr/bin/env bash
batch=$1

# Build comma-separated PMID list
pmids=$(tr '\n' ',' < "$batch" | sed 's/,$//')

# Download batch XML
outfile="../data/raw/Articles/artbatches/article-$(basename $batch).xml"
curl -fsS "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmids}&rettype=abstract&retmode=xml" \
  --output "$outfile"

# Count articles
article_count=$(xmllint --xpath "count(//PubmedArticle)" "$outfile" 2>/dev/null)

# Split into individual files
for i in $(seq 1 $article_count); do
    pmid=$(xmllint --xpath "(//PubmedArticle)[$i]//PMID/text()" "$outfile" 2>/dev/null)

    if [ -z "$pmid" ]; then
        echo "Skipping empty PMID at index $i"
        continue
    fi

    xmllint --xpath "(//PubmedArticle)[$i]" "$outfile" 2>/dev/null \
      > "../data/raw/Articles/individual/article-data-${pmid}.xml"
done

sleep 0.5
