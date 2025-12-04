library(tidyverse)
library(tm)
library(stopwords)
library(tidytext)
library(textstem)
library(topicmodels)

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




journal_corpus <- Corpus(VectorSource(journal_tsv$Title))

journal_corpus <- tm_map(journal_corpus, removeWords, stopwords(language = "english", source = "smart"))

journal_tsv$Title <- sapply(journal_corpus, as.character)

#Reduce words to stem
journal_tsv$Title <- lemmatize_strings(journal_tsv$Title)

#Remove empty titles
title_lengths <- nchar(trimws(journal_tsv$Title))
journal_tsv <- journal_tsv[title_lengths > 0, ]

#Remove NA's

#journal_tsv <- na.omit(journal_tsv)


write_tsv(journal_tsv, "journal_tsv_trimmed.tsv")


####TITLE LDA

#Create document term matrix

journal_title_dtm <- DocumentTermMatrix(journal_tsv$Title)
#journal_dtm <- removeSparseTerms(journal_dtm, 0.99)

#Create journal_lda

journal_title_lda <- LDA(journal_title_dtm, k= 2, control = list(seed = 1234))

journal_topics <- tidy(journal_title_lda, matrix = "beta")

journal_top_terms <- journal_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup()



##MESH TRIMMING





#stopwords
journal_corpus_mesh <- Corpus(VectorSource(journal_tsv$MESH_Terms))

journal_corpus_mesh <- tm_map(journal_corpus_mesh, removeWords, stopwords(language = "english",source = "smart"))

journal_tsv$MESH_Terms <- sapply(journal_corpus_mesh, as.character)

mesh_lengths <- nchar(trimws(journal_tsv$MESH_Terms))
journal_tsv <- journal_tsv[mesh_lengths > 0, ]

#journal_tsv <- na.omit(journal_tsv)

journal_tsv$MESH_Terms <- lemmatize_strings(journal_tsv$MESH_Terms)


journal_mesh_dtm <- DocumentTermMatrix(journal_tsv$MESH_Terms)



journal_mesh_lda <- LDA(journal_mesh_dtm, k= 4, control = list(seed = 1234))

journal_mesh_topics <- tidy(journal_mesh_lda, matrix = "beta")

journal_mesh_top_terms <- journal_mesh_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup()



journal_mesh_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(x = beta, y = term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered() +
  labs(
    title = "Top MESH Terms",
    x = "Beta",
    y = "MeSH Term"
  ) +
  theme_minimal()



##Abstracts Trimming and LDA






journal_tsv_abstracts_corpus <- Corpus(VectorSource(journal_tsv$Abstracts))
journal_tsv_abstracts_corpus<- tm_map(journal_tsv_abstracts_corpus, removeWords, stopwords(language = "english", source = "smart"))

journal_tsv$Abstracts <- sapply(journal_tsv_abstracts_corpus, as.character)


journal_tsv$Abstracts <- lemmatize_strings(journal_tsv$Abstracts)

journal_abstract_dtm <- DocumentTermMatrix(journal_tsv_abstracts_corpus)


journal_abstract_lda <- LDA(journal_abstract_dtm, k= 2, control = list(seed = 1234))



journal_mesh_topics <- tidy(journal_mesh_lda, matrix = "beta")

journal_mesh_top_terms <- journal_mesh_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup()



journal_mesh_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(x = beta, y = term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered() +
  labs(
    title = "Top MESH Terms",
    x = "Beta",
    y = "MeSH Term"
  ) +
  theme_minimal()

###TRIMMING FUNCTION




#stopwords
