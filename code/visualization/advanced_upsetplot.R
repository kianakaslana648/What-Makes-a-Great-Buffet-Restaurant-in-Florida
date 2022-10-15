
library(rstudioapi)
library(ggupset)
library(jsonlite)
library(tidyverse)
library(skimr)
library(ggpubr)

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
class_country<-df.unnested |> filter(categories=="American" | 
                                       categories=="Chinese" | 
                                       categories=="Japanese")

beautiful_colors <- c("#50514f", "#f25f5c", "#ffe066", "#70c1b3")
plt2 <- ggplot(class_country, aes(x = categories, fill = star_binning, width = 0.6)) +
  geom_bar()+
  labs(
    x = "Categories", y = "Number of Buffet Restaurants",
    title = "Buffet Distribution in terms of Regions",
    # caption = "XXX",
  ) +
  theme_minimal() +
  scale_fill_manual(
    name = "Review Stars", labels = c("Really bad", "Not good", "Good", "Very good"),
    values = beautiful_colors
  ) + theme(
    panel.grid = element_blank(),
    plot.title = element_text(color = "#ff1654", size = 12, face = "bold.italic", hjust = 0.5),
    axis.title.x = element_text(color = "black", size = 10, face = "bold",vjust=-1.5),
    axis.text = element_text(size = 10),
    axis.title.y = element_text(color = "black", size = 10, face = "bold", vjust = 2.5),
    legend.position = "top",
    legend.key.size = unit(1, "cm"), # change legend key size
    legend.key.height = unit(1, "cm"), # change legend key height
    legend.key.width = unit(1, "cm"), # change legend key width
    legend.title = element_text(size = 10), # change legend title font size
    legend.text = element_text(size = 10))

class_time<-df.unnested |> filter(categories=="Breakfast" | 
                                    categories=="Brunch" | 
                                    categories=="Bars")

plt3 <- ggplot(class_time, aes(x = categories, fill = star_binning)) +
  geom_bar()+
  labs(
    x = "Categories", y = " ",
    title = "Buffet Distribution in terms of Restaurant Types",
    # caption = "XXX",
  ) + ylim(0, 40)+
  theme_minimal() +
  scale_fill_manual(
    name = "Review Stars", labels = c("Really bad", "Not good", "Good", "Very good"),
    values = beautiful_colors
  ) + theme(
    panel.grid = element_blank(),
    plot.title = element_text(color = "#ff1654", size = 12, face = "bold.italic", hjust = 0.5),
    axis.title.x = element_text(color = "black", size = 10, face = "bold",vjust=-1.5),
    axis.text = element_text(size = 10),
    axis.title.y = element_text(color = "black", size = 10, face = "bold", vjust = 2.5),
    legend.position = "top",
    legend.key.size = unit(1, "cm"), # change legend key size
    legend.key.height = unit(1, "cm"), # change legend key height
    legend.key.width = unit(1, "cm"), # change legend key width
    legend.title = element_text(size = 10), # change legend title font size
    legend.text = element_text(size = 10))

combine<-ggarrange(plt2, plt3, ncol = 2, nrow = 1, 
          common.legend = TRUE, legend = "bottom")

ggsave("category_com.png", 
       plot = combine, 
       device = "png", 
       bg = "white")





