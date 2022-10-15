
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import pandas as pd

df = pd.read_csv("plot5_finalset.csv")
df.food_score = df.food_score.round(2)
df.service_score = df.service_score.round(2)
df = df.rename(columns={"star_binning":"average_rating"})
df = df[["average_rating", "food_score", "service_score", "price"]]
df["average_rating"] = df["average_rating"].astype("category")
fig = go.Figure(data=
    go.Parcoords(
        line = dict(color = df['average_rating'],
                   colorscale = 'rainbow',
                   showscale = True,
                   cmin = 1,
                   cmax = 4),
        dimensions = list([
            dict(tickvals = [1,2,3,4],
                 ticktext = ['1','2','3','4'],
                 label = 'average_rating', values = df['average_rating']),
            dict(
                 label = 'food_score', values = df['food_score']),
            dict(
                 label = 'service_score', values = df['service_score']),
            dict(tickvals = [1,2,3,4],
                 ticktext = ['$','$$','$$$','$$$$'],
                 visible = True,
                 label = 'price', values = df['price'])])
    )
)
fig.show()