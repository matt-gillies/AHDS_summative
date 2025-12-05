library(tidyverse)
library(tm)
library(stopwords)
library(tidytext)
library(textstem)
library(topicmodels)
library(ldatuning)
library(Rtsne)

file_path <- "../data/clean/journal_data_cleaned.tsv"
journal_tsv <- read_tsv(file_path)



#####Title, Abstract and Mesh trimming

#Remove uppercase characters

journal_tsv$Title <- tolower(journal_tsv$Title)

journal_tsv$MESH_Terms <- tolower(journal_tsv$MESH_Terms)

journal_tsv$Abstracts <- tolower(journal_tsv$Abstracts)




#Remove Punctuation
journal_tsv$Title <- gsub('[[:punct:]]',' ',journal_tsv$Title)

journal_tsv$MESH_Terms <- gsub('[[:punct:]]',' ',journal_tsv$MESH_Terms)

journal_tsv$Abstracts <- gsub('[[:punct:]]',' ', journal_tsv$Abstracts)



#Remove Numbers
journal_tsv$Title <- removeNumbers(journal_tsv$Title)

journal_tsv$MESH_Terms <- removeNumbers(journal_tsv$MESH_Terms)

journal_tsv$Abstracts <- removeNumbers(journal_tsv$Abstracts)


#Remove Stop Words

journal_tsv$Title <- removeWords(journal_tsv$Title, c(stopwords(language = "en", source = "snowball"), "internet", "addiction"))

journal_tsv$Abstracts <- removeWords(journal_tsv$Abstracts, c(stopwords(language = "en", source = "snowball"), "internet", "addiction"))



#Reduce words to stem
journal_tsv$Title <- lemmatize_strings(journal_tsv$Title)

journal_tsv$MESH_Terms <- lemmatize_strings(journal_tsv$MESH_Terms)

journal_tsv$Abstracts <- lemmatize_strings(journal_tsv$Abstracts)





#Write new trimmed TSV


write_tsv(journal_tsv, "../data/clean/journal_tsv_trimmed.tsv")


####TITLE LDA

#Create document term matrices

journal_abstract_dtm <- DocumentTermMatrix(journal_tsv$Abstracts[!journal_tsv$Abstracts == "" & !is.na(journal_tsv$Abstracts)])


#LDA Topic Modelling

journal_abstract_lda <- LDA(journal_abstract_dtm, k = 5, control = list(seed=123))

#Cluster Topic Modelling

journal_abstract_ctm <- CTM(journal_abstract_dtm, k = 5, control = list(seed=123))

journal-abstract_tsne <- Rtsne(journal_abstract_dtm, dims = 2, perplexity = 25, verbose = TRUE, max_iter = 1500)



ggplot(tsne_coords, aes(x = Dim1, y = Dim2, color = factor(dominant_topic))) +
       geom_point(alpha = 0.7) +
       labs(color = "Dominant Topic", title = paste("t-SNE Clustering of", ncol(doc_topics), "CTM Topics")) +
       theme_minimal()