knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE
)


#--Biblioteki--
library(tm)
library(SnowballC)
library(cluster)
library(wordcloud)
library(factoextra)
library(RColorBrewer)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(DT)
library(tidytext)
library(stringr)
library(SentimentAnalysis)
library(ggthemes)
library(tidyverse)
library(textdata)
library(forcats)

getwd()


#--Słowniki--
textdata::lexicon_afinn()
textdata::lexicon_bing()
textdata::lexicon_nrc()
textdata::lexicon_loughran()


#--Funkcja przetwarzajaca tekst--
process_text <- function(file_path) {
  text <- tolower(readLines(file_path, encoding = "UTF-8"))
  text <- removePunctuation(text)
  text <- removeNumbers(text)
  text <- removeWords(text, stopwords("en"))
  words <- unlist(strsplit(text, "\\s+"))
  words <- words[words != ""]
  words <- words[!words %in% c("—", "–", "’s", "’re")]
  wordStem(words, language = "en")
}


#--ANALIZA CZĘSTOŚCI SŁÓW--


#--Funkcja zliczająca częstość słów--
word_frequency <- function(words) {
  freq <- table(words)
  freq_df <- data.frame(word = names(freq), freq = as.numeric(freq))
  freq_df <- freq_df[order(-freq_df$freq), ]
  return(freq_df)
}


#--Funkcja tworząca chmurę słów--
plot_wordcloud <- function(freq_df, title, color_palette = "Dark2") {
  wordcloud(words = freq_df$word, freq = freq_df$freq, min.freq = 10,
            colors = brewer.pal(8, color_palette))
  title(title)
}


#--Funkcja dzieląca tekst na fragmenty co 100 słów--
split_into_chunks <- function(words, n = 100) {
  split(words, ceiling(seq_along(words)/n))
}


#--Implementacja--
file_path <- "George_Orwell.txt"
words <- process_text(file_path)
freq_df <- word_frequency(words)
plot_wordcloud(freq_df, "Chmura słów", "Dark2")
print(head(freq_df, 10))


#--Wykres_top 20 najczestszych słów--
top_words <- freq_df %>% slice_max(freq, n = 20)
ggplot(top_words, aes(x = reorder(word, freq), y = freq)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 najczęstszych słów (stemmed)", x = "Słowo", y = "Liczba") +
  theme_minimal()


#--Konwersja do tibble--
words_df <- tibble(word = words)
stop_words <- stop_words
words_clean <- words_df %>% anti_join(stop_words, by = "word")


#--Tokenizacja tekstu z oryginału (dla unnest_tokens)--
raw_text <- readLines(file_path, encoding = "UTF-8")
tokeny <- data.frame(Review = raw_text, stringsAsFactors = FALSE)
tidy_tokeny <- tokeny %>%
  unnest_tokens(word, Review) %>%
  anti_join(stop_words, by = "word")


#--ANALIZA SENTYMENTU--


#--Słownik Bing--
sentiment_bing <- tidy_tokeny %>%
  inner_join(get_sentiments("bing"))
sentiment_summary <- sentiment_bing %>% count(sentiment)


#--Wykres_sentyment(Bing)
ggplot(sentiment_summary, aes(x = sentiment, y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Sentyment (Bing)", x = "Sentyment", y = "Liczba") +
  theme_minimal()


#--Top słowa Bing--
top_bing <- sentiment_bing %>%
  count(word, sentiment, sort = TRUE) %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10) %>%
  ungroup()


#Wykres_Top 10 słów wg sentymentu (Bing)--
ggplot(top_bing, aes(x = reorder(word, n), y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ sentiment, scales = "free") +
  coord_flip() +
  labs(title = "Top 10 słów wg sentymentu (Bing)", x = "Słowo", y = "Liczba") +
  theme_minimal()


#--Analiza sentymentu dla pozostałych słowników--
get_sentiment_plot <- function(tidy_data, lexicon, title, filter_val = NULL, fill_manual = NULL) {
  sent <- tidy_data %>%
    inner_join(get_sentiments(lexicon), relationship = "many-to-many")
  
  if (!is.null(filter_val)) {
    sent <- sent %>% filter(sentiment %in% filter_val)
  }
  
  word_counts <- sent %>%
    count(word, sentiment) %>%
    group_by(sentiment) %>%
    top_n(10, n) %>%
    ungroup() %>%
    mutate(word2 = fct_reorder(word, n))
  
  ggplot(word_counts, aes(x = word2, y = n, fill = sentiment)) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~sentiment, scales = "free") +
    coord_flip() +
    labs(x = "Słowa", y = "Liczba", title = title) +
    theme_gdocs() +
    scale_fill_manual(values = fill_manual %||% c("firebrick", "darkolivegreen4"))
}


#--Dla słownika NRC--
get_sentiment_plot(tidy_tokeny, "nrc", "Sentyment (NRC)", c("positive", "negative"))


#--Dla słownika Loughran--
get_sentiment_plot(tidy_tokeny, "loughran", "Sentyment (Loughran)", c("positive", "negative"))


#--Dla słownika Afinn--
sent_afinn <- tidy_tokeny %>%
  inner_join(get_sentiments("afinn")) %>%
  filter(value %in% c(-5:-3, 3:5)) %>%
  count(word, value) %>%
  group_by(value) %>%
  top_n(5, n) %>%
  ungroup() %>%
  mutate(word2 = fct_reorder(word, n))

#--Wykres_Silne słowa wg sentymentu (Afinn)--
ggplot(sent_afinn, aes(x = word2, y = n, fill = as.factor(value))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~value, scales = "free") +
  coord_flip() +
  labs(x = "Słowa", y = "Liczba", title = "Silne słowa wg sentymentu (Afinn)") +
  theme_gdocs()


#--KLASTROWANIE--


#--Podział na fragmenty--
chunks <- split_into_chunks(words, 100)
documents <- sapply(chunks, paste, collapse = " ")
names(documents) <- paste0("Fragment_", seq_along(documents))
corpus <- VCorpus(VectorSource(documents))

tdm <- TermDocumentMatrix(corpus)
dtm_m <- t(as.matrix(tdm))


#--Dobór liczby klastrów--
set.seed(123)
fviz_nbclust(dtm_m, kmeans, method = "silhouette") +
  labs(title = "Dobór liczby klastrów (Silhouette)")


#--Zakładamy k=3--
k <- 3
klastrowanie <- kmeans(dtm_m, centers = k)


#--Wykres_Wizualizacja klastrów--
fviz_cluster(list(data = dtm_m, cluster = klastrowanie$cluster),
             geom = "point",
             main = paste("Wizualizacja klastrów (k =", k, ")"))


#--Podsumowanie klastrów--
cluster_info <- lapply(1:k, function(i) {
  idx <- which(klastrowanie$cluster == i)
  word_freq <- sort(colSums(dtm_m[idx, , drop = FALSE]), decreasing = TRUE)
  data.frame(
    Klaster = i,
    Liczba_fragmentów = length(idx),
    Top_5_słów = paste(names(word_freq)[1:5], collapse = ", "),
    stringsAsFactors = FALSE
  )
})


#--Tabela przypisania fragmentów do klastrów--
cluster_info_df <- do.call(rbind, cluster_info)
documents_clusters <- data.frame(
  Dokument = names(documents),
  Klaster = klastrowanie$cluster,
  stringsAsFactors = FALSE
)


#--Stworzenie interaktywnej tabeli z pełnym podsummowaniem--
datatable(
  merge(documents_clusters, cluster_info_df, by.x = "Klaster", by.y = "Klaster"),
  caption = "Podsumowanie klastrów i fragmentów"
)

