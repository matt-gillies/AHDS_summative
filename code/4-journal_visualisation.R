library(tidyverse)
library(tm)
library(stopwords)
library(tidytext)
library(textstem)
library(topicmodels)
library(stm)
library(Rtsne)





file_path <- "../data/clean/journal_data_cleaned.tsv"


journal_tsv <- read_tsv(file_path)



#####Title, Abstract and Mesh trimming

#Remove uppercase characters

journal_tsv$Abstract <- tolower(journal_tsv$Abstract)




#Remove Punctuation

journal_tsv$Abstract <- gsub('[[:punct:]]',' ', journal_tsv$Abstract)



#Remove Numbers

journal_tsv$Abstract <- removeNumbers(journal_tsv$Abstract)


#Remove Stop Words

journal_tsv$Abstract <- removeWords(journal_tsv$Abstract, c(stopwords(language = "en", source = "snowball"), "internet", "addiction"))



#Reduce words to stem

journal_tsv$Abstract <- lemmatize_strings(journal_tsv$Abstract)





#Write new trimmed TSV


#write_tsv(journal_tsv, "../data/clean/journal_tsv_trimmed.tsv")




#Structural Topic Modelling

journal_tsv_stm_prep <- textProcessor(documents = journal_tsv$Abstract, stem = FALSE, removestopwords = FALSE)

#topicnumber <- searchK(journal_tsv_stm_prep$documents, journal_tsv_stm_prep$vocab, K = c(3:6), data = journal_tsv_stm_prep$meta)

journal_abstract_stm <- stm(journal_tsv_stm_prep$documents, journal_tsv_stm_prep$vocab, K = 6, data = journal_tsv_stm_prep$meta, init.type = "Spectral", seed = 123)


#TSNE cluster

#https://medium.com/data-science/visualizing-topic-models-with-scatterpies-and-t-sne-f21f228f7b02


abstract_stm_thetas <- jitter(journal_abstract_stm$theta, amount = 1e-8 )


set.seed(123)
abstract_tsne <- Rtsne(as.matrix(abstract_stm_thetas), dims = 2, perplexity = 25, verbose = TRUE, pca = TRUE)

dominant_topic <- apply(abstract_stm_thetas, 1, which.max)



tsne_plot_frame <- data.frame(
  X = abstract_tsne$Y[,1],
  Y = abstract_tsne$Y[,2],
  Topic = factor(dominant_topic)
)

top_terms_all <- labelTopics(journal_abstract_stm, n=6)
top_terms_score <- apply(top_terms_all$score, 1, paste, collapse = ", ")
topic_labels <- paste0("Topic ", seq_along(top_terms_score), ": ", top_terms_score)
levels(tsne_plot_frame$Topic) <- topic_labels


png(filename = "../data/clean/abstract_tsne_clustering.png", width = 1000, height = 425)

ggplot(tsne_plot_frame, aes(x = X, y = Y, color = Topic)) +
  geom_point(alpha = 0.7, size = 0.5) +
  theme_minimal() +
  ggtitle("t-SNE Clustering of STM Topics")
dev.off()



