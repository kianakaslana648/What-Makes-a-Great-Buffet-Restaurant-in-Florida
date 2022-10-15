library(rstudioapi)
library(ggupset)
library(jsonlite)
library(tidyverse)
library(skimr)


setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
df <- read.csv("yelp_dataset/buffet_restaurants.csv")
# View(df)
df <- df |> select(c("business_id", "name", "city", "state", "categories", "review_count", "stars"))
df <- df |> mutate(star_binning = case_when(
  stars >= 1 & stars <= 2 ~ "1",
  stars > 2 & stars <= 3 ~ "2",
  stars > 3 & stars <= 4 ~ "3",
  stars > 4 & stars <= 5 ~ "4"
))
df$star_binning <- as.factor(df$star_binning)

df.unnested <- df |> separate_rows(categories)
df.unnested <- df.unnested |> filter(categories != "Restaurants" & categories != "Food")

category.mostcommon <- group_by(df.unnested, categories) %>%
  summarise(freq = n()) |> 
  filter(freq>=3) |> 
  arrange(desc(freq))
category.mostcommon$categories


# regions_large3<-c("American","Chinese","Japanese", "Indian", "Latin","Halal","Spanish", "Pakistani","Brazilian")

regions_large3<-c("Seafood","Sushi","Pizza", "Wine","Steakhouses","Barbeque","Vegetarian","Beer")

df_regions <- df.unnested[df.unnested$categories %in% regions_large3, ]
regions_id <- df_regions$business_id |> unique()
df_regions_others <- df.unnested[!(df.unnested$categories %in% regions_large3), ]
df_regions_others$categories <- "Others"
df_regions_others <- df_regions_others[!(df_regions_others$business_id %in% regions_id), ] |> unique()
df_regions2 <- bind_rows(df_regions, df_regions_others)


df_scores <- read.csv("yelp_dataset/scores_all_raw.csv")


regions_radar <- df_regions2 |>
  inner_join(df_scores, by = "business_id") |>
  select(
    business_id, name.x, categories, review_count, stars, Food.Score, Service.Score, Environment.Score,
    Variety.Score, Music.Score, Drink.Score, Sauce.Score,
  ) |> rename(name = name.x)
regions_radar  |> select(business_id) |> unique()
regions_radar[regions_radar$categories=="Others",] |> select(business_id) |> unique()

colSums(is.na(regions_radar))
# remove music score because most restaurants lack the music score
# replace NA in scores with average value
str(regions_radar)
regions_radar <- regions_radar %>%
  mutate_at(vars(Service.Score, Environment.Score, Variety.Score, Drink.Score, Sauce.Score), ~ replace_na(., mean(., na.rm = TRUE))) |>
  select(-Music.Score)


regions_radar[regions_radar == "Wine"] <- "Beer"


regions_score <- regions_radar |>
  group_by(categories) |>
  summarise(
    Food = mean(Food.Score), Service = mean(Service.Score),
    Environment = mean(Environment.Score), Variety = mean(Variety.Score),
    Drink = mean(Drink.Score), Sauce = mean(Sauce.Score),
    Stars=mean(stars),Reviews=mean(review_count), Counts=n()
  ) |>
  rename(category = categories) 
regions_score[regions_score$category!="Others" & regions_score$category!="Beer",]|> select(category,Counts) |> rename(Value=Counts,Category=category) |> 
  write.csv("foods_category_distribution.csv",row.names = FALSE)


regions_score |> select(category,Stars,Reviews) |> arrange(desc(Stars))
regions_score<-regions_score[regions_score$category!="Breakfast",] |> select(-c(Stars,Reviews,Counts))

regions_score <- regions_score |> pivot_longer(cols = c(Food, Service, Environment, Variety, Drink, Sauce), names_to = "aspect")
x <- toJSON(regions_score)
write(x, "foods_copy.json")
