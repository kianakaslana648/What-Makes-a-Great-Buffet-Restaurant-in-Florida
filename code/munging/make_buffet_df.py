import numpy as np
import pandas as pd

restaurant = pd.read_csv("../restaurant_df.csv")
buffet = restaurant[restaurant["categories"].str.contains("Buffet")]
florida_buffet = buffet[buffet["state"] == "FL"]
print(len(florida_buffet))
florida_buffet

reviews = pd.read_csv("../review_aspect_attr.csv")
florida_reviews = florida_buffet.merge(reviews, on="business_id")
reviews = pd.read_csv("../buffet_reviews.csv")
buffet = reviews.merge(restaurant, on="business_id")

