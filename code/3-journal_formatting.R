##Data Download and Formatting
library(ggplot2)
library(tidyverse)
library(xml2)
library(parallel)


file_path <- "../data/raw/Articles/individual"

journal_names <- list.files(file_path, pattern = "*.xml", full.names = TRUE)


journal_data_raw <- lapply(journal_names, read_xml)
#print(journal_names)


PMIDs <- c()
for (i in seq_along(journal_data_raw)){
  PMID <- xml_integer(xml_find_first(journal_data_raw[[i]], ".//PMID"))
  PMIDs <- c(PMIDs ,PMID)
}

Years <- c()
for (i in seq_along(journal_data_raw)){
  Year <- xml_text(xml_find_first(journal_data_raw[[i]], ".//Year"))
  Years <- c(Years,Year)
}

Titles <- c()
for (i in seq_along(journal_data_raw)){
  Title <- xml_text(xml_find_first(journal_data_raw[[i]], ".//ArticleTitle"))
  Titles <- c(Titles, Title)
}


Abstracts <- c()

for (i in seq_along(journal_data_raw)) {
  Abstract_nodes <- xml_find_all(journal_data_raw[[i]], ".//Abstract")
  Abstract <- xml_text(Abstract_nodes)
  
  if (length(Abstract) != 0){
    Abstracts[i] <- paste(Abstract)
  }
  else{
    Abstracts[i] <- NA
  }
}
  

journal_table <- tibble(PMID = PMIDs, Title=Titles, Year = Years, Abstract = Abstracts)
write_tsv(journal_table, "../data/clean/journal_data_cleaned.tsv")





