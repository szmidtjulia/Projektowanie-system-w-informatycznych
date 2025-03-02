install.packages("wordcloud")
library(wordcloud)

# Wczytaj dane tekstowe
text21 <- readLines(biden2021psi.txt())
text
text24 <- readLines(biden2024psi.txt())

# Opcje chmury słów
?wordcloud
?brewer.pal
brewer.pal.info

# Analiza częstości występowania słów
frequent_terms <- freq_terms(text)
frequent_terms
frequent_terms <- freq_terms(text, stopwords = Top200Words)
plot(frequent_terms)

# Dodanie różnych palet kolorystycznych
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, min.freq = 4, colors = brewer.pal(9,"Blues"))
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, min.freq = 4, colors = brewer.pal(9,"Reds"))
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, min.freq = 4, colors = brewer.pal(9,"Greens"))

# Tworzenie chmury słów
wordcloud(frequent_terms$WORD, frequent_terms$FREQ)

# Ograniczenie liczby słów w chmurze poprzez minimalną częstość
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, min.freq = 4)

# Ograniczenie liczby słów w chmurze poprzez maksymalną liczbę słów
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, max.words = 5)

# Dodanie koloru do chmury słów dla lepszej wizualizacji
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, min.freq = 4, colors = brewer.pal(8,"Dark2"))
wordcloud(frequent_terms$WORD, frequent_terms$FREQ, max.words = 5, colors = brewer.pal(8,"Accent"))