# Zadanie 1. Analiza pojedynczego zdania ----

# Wczytaj dane tekstowe
text <- "And so even though we face the difficulties of today and tomorrow, I still have a dream."
text

# SprawdŸ czêstoœci s³ów za pomoc¹ pakietu qdap
install.packages("qdap")
library(qdap)

freq_terms(text)

# Zapisz najczêœciej wystêpuj¹ce terminy w ramce danych
frequent_terms <- freq_terms(text)
frequent_terms

# Wizualizacja najczêœciej wystêpuj¹cych terminów
plot(frequent_terms)

# UWAGA
# S³owa nie s¹ wymienione w takiej kolejnoœci, w jakiej wystêpuj¹ w zdaniu
# s¹ prezentowane w porz¹dku alfabetycznym.
# Takie podejœcie nazywa siê Bag of Words (torba s³ów).

# Inne mo¿liwoœci pakietu qdap
?freq_terms

# Wizualizacja za pomoc¹ ggplot2
library(ggplot2)

ggplot(frequent_terms, aes(x = WORD, y = FREQ)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(x = "S³owo", y = "Czêstoœæ") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Wykres czêstoœci s³ów")

ggplot(frequent_terms, aes(y = WORD, x = FREQ)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(x = "S³owo", y = "Czêstoœæ") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1)) +
  ggtitle("Wykres czêstoœci s³ów")

# Bardziej atrakcyjna wizualizacja
ggplot(frequent_terms, aes(x = FREQ, y = reorder(WORD, FREQ))) +
  geom_bar(stat = "identity", fill = "skyblue", color = "darkblue", alpha = 0.8) +
  labs(x = "Czêstoœæ", y = "S³owo") +
  ggtitle("Wykres czêstoœci s³ów") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 10), # Dostosowanie rozmiaru czcionki etykiet na osi Y
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"), # Wyœrodkowanie i stylizacja tytu³u wykresu
        panel.grid.major.y = element_blank(), # Usuniêcie g³ównych linii siatki poziomej
        panel.grid.minor.y = element_blank(), # Usuniêcie mniejszych linii siatki poziomej
        axis.line = element_line(color = "black")) # Dostosowanie linii osi

# Stopwords (stop s³owa – s³owa do usuniêcia)
# Najczêœciej wystêpuj¹ce 25, 100 i 200 s³ów

Top25Words
Top100Words
Top200Words

# Usuniêcie stop s³ów
frequent_terms2 <- freq_terms(text, stopwords = Top25Words)
frequent_terms3 <- freq_terms(text, stopwords = Top100Words)
frequent_terms4 <- freq_terms(text, stopwords = Top200Words)

plot(frequent_terms4)

# Zadanie 2. Analiza ca³ego akapitu ----

# Wczytaj dane tekstowe
text <- "And so even though we face the difficulties of today and tomorrow, I still have a dream. It is a dream deeply rooted in the American dream."
text

frequent_terms <- freq_terms(text)
frequent_terms
frequent_terms <- freq_terms(text, stopwords = Top200Words)
plot(frequent_terms)

