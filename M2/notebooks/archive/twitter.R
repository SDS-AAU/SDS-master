
###################################################
# Setup
###################################################


### Generic preamble
rm(list=ls())
Sys.setenv(LANG = "en") # For english language
options(scipen = 5) # To deactivate annoying scientific number notation
set.seed(1337) # To have a seed defined for reproducability

### Install packages if necessary
if (!require("pacman")) install.packages("pacman") # package for loading and checking packages :)
pacman::p_load(tidyverse, # Standard datasciewnce toolkid (dplyr, ggplot2 et al.)
               magrittr, # For advanced piping (%>% et al.)
               rtweet, # For twitter scraping
               tidytext, # For text analysis
               tm, # text mining library
               quanteda, # adittional textmining
               text2vec, # vor text vectorization
               topicmodels, # for LDA analysis
               tidygraph, # for networks
               ggraph, # for network viz
               wordcloud # For making wordclouds
               )


###################################################
# Download tweets
###################################################

# whatever name you assigned to your created app
appname <- "sds_datacrunch"
key <- "nopR6CJyjKDjpiUjCoaETMHzb"
secret <- "uHdmbi2DxS5e2VFDooZVgPE3KYxDwTrNx48rWS6U3V4HSCBU4r"
key_acess <- "804093373-DMsmElFNtpyiIO3fJtA15cFzIuFfSIQpStXj30Hx"
key_secret <- "fWTur6bD3aqB3jQ0xMVgSPqUeRzoxUxi4xgSFhOM3DkFE"


## authenticate via access token
token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret,
  access_token = key_acess,
  access_secret = key_secret)

rate_limit(token)

terms <- c("#rstats", "#rstudio", "#tidyverse", "#tidytuesday", "#rladies", "#ggplot", "#tidygraph", "#ggraph", 
           "tidytext", "quanteda", "#spaCy", "NLP", "#dataviz", "machinelearning")

# Search tweets
rstats_tweets <- search_tweets(q = paste(terms, collapse = " OR "),
                               n = 30000, 
                               include_rts = FALSE,
                               verbose = TRUE,
                               retryonratelimit = TRUE,
                               lang = "en",
                               token = token)

saveRDS(rstats_tweets, "data/rstats_tweets_no_rt.rds")

tweets <- rstats_tweets
rm(rstats_tweets)
###################################################
# Analysis
###################################################

tweets %>% head()

tweets %>% glimpse()

## plot time series of tweets
tweets %>%
  ts_plot("3 hours") +
  labs(x = NULL, y = NULL,
    title = "Frequency of #rstats Twitter statuses from past 7 days",
    subtitle = "Twitter status (tweet) counts aggregated using three-hour intervals",
    caption = "Source: Data collected from Twitter's REST API via rtweet"
  )

tweets %>% 
  count(screen_name, sort = TRUE) %>%
  top_n(20)


###################################################
# Tweets
###################################################


id <- tweets %>% count(user_id, sort = TRUE) %>% filter(n > 1) 
users <- lookup_users(id, token = token)

users <- attr(id, "users") %>%
  distinct(user_id, .keep_all = TRUE)








el_mentions <- tweets %>% 
  select(user_id, mentions_user_id) %>%
  unnest() %>%
  drop_na() %>% 
  count(user_id, mentions_user_id) %>%
  rename(from = user_id,
         to = mentions_user_id,
         weight = n) %>%
  filter(weight > 1)

g_mentions <- as_tbl_graph(el_mentions, directed = TRUE) %N>%
  inner_join(users %>% select(user_id, screen_name, location, description, followers_count, friends_count, listed_count, statuses_count, favourites_count),
            by = c("name" = "user_id"))

g_mentions <- g_mentions %N>%
  filter(!node_is_isolated()) %N>%
  mutate(cent_dgr = centrality_degree(weights = weight, mode = "in"),
         com = group_edge_betweenness(weights = weight, directed = TRUE) %>% as.factor())

g_mentions %>% ggraph(layout = "fr") + 
  geom_edge_fan(aes(edge_width = weight), alpha = 0.25) +
  geom_node_point(aes(size = cent_dgr, color = com)) +
  geom_node_text(aes(label = screen_name)) +
  theme_graph() 



# Hashtags
hashtags <- tweets %>% select(text) %>% 
  mutate(hashtag = text %>% str_to_lower() %>% str_extract_all("\\#[:alpha:]*")) %>%
  select(hashtag) %>%
  unnest(hashtag) %>%
  count(hashtag, sort = TRUE)

# Hashtags network
el_hashtags <- tweets %>% select(status_id, text) %>% 
  mutate(from = text %>% str_to_lower() %>% str_extract_all("\\#[:alpha:]*"),
         to = from) %>%
  select(-text) %>%
  unnest(from, .drop = FALSE) %>%
  unnest(to, .drop = FALSE) %>%
  count(from, to, sort = TRUE, name = "weight") %>%
  filter(from != to)

###################################################
# NLP simple
###################################################


# Tidy NLP
tweets %>% 
  select(user_id, status_id, text) %>%
  unnest_tokens(output = word, input = text) %>%
  count(word, sort = TRUE) %>%
  head(20)

stop_words

# remove stopwords
tweets %>% 
  select(user_id, status_id, text) %>%
  unnest_tokens(output = word, input = text) %>%
  anti_join(stop_words, by = "word") %>%
  count(word, sort = TRUE) %>%
  head(20)


own_stopwords <- tibble(word= c("t.co", "https", "amp", "rstats"),
                        lexicon = "OWN")


tweets_tidy <- tweets %>% 
  select(user_id, status_id, text) %>%
  unnest_tokens(output = word, input = text) %>%
  anti_join(stop_words %>% bind_rows(own_stopwords), by = "word") %>%
  mutate(word = word %>% str_remove_all("[^[:alnum:]]") ) %>%
  filter(str_length(word) > 1) 


topwords <- tweets_tidy %>%
  count(word, sort = TRUE) 

topwords %>%
  ggplot(aes(x = n)) + 
  geom_histogram()


topwords %>%
  top_n(20, n) %>%
  ggplot(aes(x = word %>% fct_reorder(n), y = n)) +
  geom_col() +
  coord_flip() +
  labs(title = "Word Counts", x = "Frequency", y = "Top Words")
  

# plot the 50 most common words
wordcloud(topwords$word, topwords$n, random.order = FALSE, max.words = 50, colors = brewer.pal(8,"Dark2"))


topwords %>%
  filter(n > 1) %>%
  DT::datatable()






### DTM


tweets_dtm <- tweets_tidy %>%
  count(status_id, word) %>%
  cast_dtm(document = status_id, term = word, value = n, weighting = tm::weightTf)

tweets_dtm

tweets_dtm %>% removeSparseTerms(sparse = .99)
tweets_dtm %>% removeSparseTerms(sparse = .999)
tweets_dtm %>% removeSparseTerms(sparse = .9999)

tweets_dtm %<>% removeSparseTerms(sparse = .9999)

### LDA
tweets_lda <- tweets_dtm %>% 
  LDA(k = 4, method = "Gibbs",
      control = list(seed = 1337))

# betas
tweets_lda %>% 
  tidy(matrix = "beta") %>%
  head()


tweets_lda %>% 
  tidy(matrix = "beta") %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  arrange(topic, -beta) %>%
  DT::datatable()


# gammas
tweets_lda %>% 
  tidy(matrix = "gamma") %>%
  head()

tweets_lda %>% 
  tidy(matrix = "gamma") %>%
  spread(key = topic, value = gamma, sep = "") %>%
  head()

top_topics <- tweets_lda %>% 
  tidy(matrix = "gamma")  %>%
  group_by(document) %>%
  top_n(1, wt = gamma) %>%
  ungroup()

top_topics %>%
  count(topic)


topic_terms <- tweets_lda %>% 
  tidy(matrix = "beta") %>%
  group_by(topic) %>%
  arrange(topic, desc(beta)) %>%
  slice(1:10) %>%
  ungroup() %>%
  arrange(topic, beta) %>%
  mutate(order = row_number()) 

topic_terms %>%
  ggplot(aes(x = order, y = beta, fill = topic %>% factor())) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 2, scales = "free") +
  scale_x_continuous(
    breaks = topic_terms$order,
    labels = topic_terms$term,
    expand = c(0,0) ) +
  labs(title = "LDA topic model",
       subtitle = "Results on 4 topics",
       x = "Words in topic",
       y = "Intra-topic distribution of word",
       caption = "Data: #rstats tweets") +
  coord_flip()


### LSA 
tweets_dfm <- tweets_tidy %>%
  count(status_id, word) %>%
  cast_dfm(document = status_id, term = word, value = n)

tweets_lsa <- tweets_dfm %>%
  textmodel_lsa(nd = 5)
  
tweets_lsa

tweets_lsa_loading <- tweets_lsa$docs %>%
  as.data.frame() %>%
  rownames_to_column(var = "statis_id") %>% 
  as_tibble()

tweets_lsa_loading



### Word embeddings


# Generate corpus
tweets_corpus <- tweets %>% corpus(docid_field = "status_id", text_field = "text")


# Generate tokens
tweet_toks <- tokens(tweets_corpus, what = "word") %>%
  tokens_tolower() %>%
  tokens(remove_punct = TRUE, 
         remove_symbols = TRUE)  



feats <- dfm(tweet_toks, verbose = TRUE) %>%
  dfm_trim(min_termfreq = 5) %>%
  featnames()


tweet_fcm <- fcm(tweet_toks, 
                 context = "window", 
                 count = "weighted", 
                 weights = 1 / (1:5), 
                 tri = TRUE)




glove <- GlobalVectors$new(word_vectors_size = 50, vocabulary = featnames(tweet_fcm), x_max = 10)
tweet_word_vectors <- fit_transform(tweet_fcm, glove, n_iter = 20)


tweet_word_vectors %<>% as.data.frame() %>%
  rownames_to_column(var = "word") %>% 
  as_tibble()


tweets_tidy2 <- tweet_toks %>% dfm() %>% tidy()

tweet_vectors <- tweets_tidy2 %>%
  inner_join(tweet_word_vectors, by = c("term" = "word"))

tweet_vectors %<>%
  group_by(document) %>%
  summarise_all(mean)



