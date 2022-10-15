import json
import os
import numpy as np
import pandas as pd
from tqdm import tqdm
import re
import string
import nltk
from nltk.corpus import stopwords
import spacy
from collections import Counter 
import statsmodels.api as sm
from scipy import stats
import matplotlib.pyplot as plt
from numpy import array
from textblob import TextBlob

data = pd.read_csv("../buffet_reviews.csv")
result = [tokenize(x) for x in data.text]
nlp = spacy.load("en_core_web_lg")


aspects = []
with tqdm(total=len(data)) as pbar:
    for i in range(len(data)):
        biz_id = data.loc[data.index[i], "business_id"]
        text = data.loc[data.index[i], "text"]
        review_id = data.loc[data.index[i], "review_id"]
        doc = nlp(text)
        descriptive_term = ''
        target = ''
        for token in doc:
            if token.dep_ != 'nsubj' and token.pos_ != 'NOUN':
                continue
            for child in token.children:
                if child.pos_ == "ADJ" or child.pos_ == "ADV":
                    aspects.append([biz_id, review_id, token.text, child.text, 
                                    TextBlob(child.text).sentiment.polarity])
        pbar.update()

aspects_df = pd.DataFrame(data=aspects, columns=["business_id", "review_id",
                "aspect", "description", "polarity"])
aspects_df