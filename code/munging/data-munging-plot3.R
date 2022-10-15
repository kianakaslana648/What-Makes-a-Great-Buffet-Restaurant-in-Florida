library(jsonlite)
library(tidyverse)
library(plotly)
library(janitor)
library(ggplot2)

### After downloading yelp_dataset.tar, unzip
### it two times and then you get all the json
### files.

raw <- readr::read_csv('data/buffet_reviews.csv') %>% 
  janitor::clean_names()

#head(raw)

json_file <- 'data/yelp_academic_dataset_business.json'
raw_biz <- jsonlite::stream_in(file(json_file))
#head(raw_biz)

biz_subset <- raw_biz %>% 
  select(c('business_id', 'state', 'review_count', 'stars'))



df <- left_join(raw, biz_subset, by = 'business_id', )
df['year_month'] <- format(df$date, "%Y-%m")


df <- df %>% select(c('review_count', 'state', 'year_month', 'stars.x'))


write_csv(df, 'data-munging-plot3.csv')