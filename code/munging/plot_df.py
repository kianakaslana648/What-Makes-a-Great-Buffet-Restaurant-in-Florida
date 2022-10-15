import numpy as np
import pandas as pd


data = pd.read_csv("../buffet_restaurants.csv")
reviews = pd.read_csv("../buffet_reviews.csv")
reviews = reviews.rename(columns={"stars":"review_stars"})
data = data.merge(reviews, on="business_id")
aspect = pd.read_csv("../buffet_review_aspect.csv")
data = data.merge(aspect, on=["business_id","review_id"])
data["aspect"] = data["aspect"].str.lower()
data["description"] = data["description"].str.lower()
data.loc[data["description"]=="inferior", "polarity"] = -0.5
data = data[data["review_count"] > 6]
data.to_csv("plot_df.csv", index=False)