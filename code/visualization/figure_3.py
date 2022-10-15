import pandas as pd
import altair as alt
import os
import sys

# Read in the cleaned data
df = pd.read_csv('data-munging-plot3.csv')

# Create a table and group by 'state' and 'year_month' column
df.year_month = df.year_month.astype(str).str[0:4].astype("datetime64[ns]")
df = df.groupby(["state", "year_month"], as_index=False).agg(
    {"review_count": "sum", "stars.x": "mean"})
df = df.rename(columns={"stars.x": "star"})
df = df.loc[df["state"] != "BC", ]
df = df.loc[df.year_month != '2021-01-01']


# selections
source = df

# Set event for animation
brush = alt.selection_interval(encodings=["x"])
click = alt.selection_multi(fields=["state"])
state_list = list(set(df.state.tolist()))
scale = alt.Scale(domain=state_list)
color = alt.Color("state:N", scale=scale)

# Line plot of Review Counts
scatter = alt.Chart(source).mark_line().encode(
    x=alt.X("year_month:T", title='Date'),
    # ,scale=alt.Scale(domain=[a,b])
    y=alt.Y("review_count:Q", title="Review counts"),
    color=alt.condition(brush, color, alt.value('lightgray')),
    tooltip=[alt.Tooltip('year_month', title='Date'), alt.Tooltip(
        'state', title='State'), alt.Tooltip('review_count', title='Review count')]
).properties(
    width=500,
    height=200,
    #title="Change of review counts with time"
).add_selection(brush).transform_filter(click)

# Bar plot of Review Stars
bar = alt.Chart(source).mark_bar().encode(
    x=alt.X("star:Q", title="Stars", scale=alt.Scale(domain=[0, 5])),
    y=alt.Y("state:N", title="States"),
    color=alt.condition(click, color, alt.value("lightgray"))
).properties(
    width=500,
    height=200
).add_selection(click).transform_filter(brush)

# Concatenate Line plot and Bar plot
alt.vconcat(scatter, bar).configure(background="#f5efe0", font="Georgia").configure_view(fill="#f5efe0").configure_title(fontSize=20, align="center", anchor="middle"). \
    configure_legend(titleColor='black', labelFontSize=17, titleFontSize=17). \
    configure_axis(labelFontSize=15, titleFontSize=17).save("plot3.html")
