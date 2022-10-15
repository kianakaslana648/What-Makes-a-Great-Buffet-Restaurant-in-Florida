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

######## remove categories that are not in yelp restaurant categories list
# restaurant_categories<-read.csv("restaurant_categories.csv")
# restaurant_categories<-restaurant_categories$x
# nrow(df.unnested)
# df.unnested<-df.unnested |> filter(categories %in% restaurant_categories)

category.mostcommon <- group_by(df.unnested, categories) %>%
  summarise(freq = n()) %>%
  top_n(8, wt = freq)

category.plotdata <- filter(df.unnested, categories %in% category.mostcommon$categories) %>%
  group_by(business_id, star_binning) %>%
  mutate(categories = list(sort(categories))) %>%
  unique()
beautiful_colors <- c("#50514f", "#f25f5c", "#ffe066", "#70c1b3")
plt <- ggplot(category.plotdata, aes(x = categories, fill = star_binning, width = 0.6)) +
  geom_bar() +
  scale_x_upset(n_intersections = 30) +
  labs(
    x = "Combination of Categories", y = "Number of Buffet Restaurants",
    title = "The Category Distribution of Buffet Restaurants in Florida",
    # caption = "XXX",
  ) +
  theme_minimal() +
  scale_fill_manual(
    name = "Review Stars", labels = c("Really bad", "Not good", "Good", "Very good"),
    values = beautiful_colors
  ) +
  theme_combmatrix(
    combmatrix.label.make_space = TRUE,
    combmatrix.panel.point.size = 2,
    combmatrix.panel.line.size = 0.4,
    combmatrix.panel.point.color.fill = "#549490",
    combmatrix.panel.point.color.empty = "#f6e0d5",
    combmatrix.label.text = element_text(size = 14),
    panel.grid = element_blank(),
    plot.title = element_text(color = "#ff1654", size = 18, face = "bold.italic", hjust = 0.5),
    axis.title.x = element_text(color = "black", size = 16, face = "bold"),
    axis.text = element_text(size = 14),
    axis.title.y = element_text(color = "black", size = 16, face = "bold", vjust = 0),
    plot.caption = element_text(color = "grey", size = 10, face = "bold.italic"),
    legend.position = c(0.8, 0.6),
    legend.key.size = unit(1, "cm"), # change legend key size
    legend.key.height = unit(1, "cm"), # change legend key height
    legend.key.width = unit(1, "cm"), # change legend key width
    legend.title = element_text(size = 16), # change legend title font size
    legend.text = element_text(size = 14)
  )
plt
# ggplotly(plt, tooltip = c("text"))

ggsave("category_1.png", 
       plot = plt, 
       device = "png", 
       bg = "white")

