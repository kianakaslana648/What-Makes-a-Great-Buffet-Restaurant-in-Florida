import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px

data = pd.read_csv("plot_df.csv")


food_words = set(["food", "taste", "tastes", "foods", "meal","meals","breakfast"])
food_df = data[data["aspect"].isin(food_words)]
food_scores = food_df.groupby(["business_id", "name"],
                    as_index=False).agg({"polarity":'mean'})
food_scores = food_scores.rename(columns={"polarity":"food_score"})


service_words = ["staff", "staffs", "waiter", "waiters", "service",
                "server", "waitress", "servers"]
service_df = data[data["aspect"].isin(service_words)]
service_scores = service_df.groupby(["business_id", "name"],
                    as_index=False).agg({"polarity":'mean'})
service_scores = service_scores.rename(columns={"polarity":"service_score"})

scores = food_scores.merge(service_scores, on=["business_id", "name"])

rest_scores = data[["business_id", "name", "stars", "review_count"]].drop_duplicates()
plot_df = scores.merge(rest_scores, on=["business_id", "name"])

fig = px.scatter(plot_df, x="food_score", y="service_score",
                 color='stars', hover_data=['food_score'], hover_name="name",
                 size="review_count"
                )
#fig.update_traces(marker_size=15)
fig.show()
fig.write_html("score.html")