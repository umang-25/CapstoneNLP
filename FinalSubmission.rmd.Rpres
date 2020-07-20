Word Prediction App
========================================================
author: Umang Gupta
date: 20/7/2020 
autosize: true

Introduction to the Capstone Project - Text Prediction Shiny App
========================================================

This capstone project was done as part of the Coursera Data Science Specialization from John Hopkins University and it was aimed at creating a text prediction app on the lines of SwiftKey(one of the leading companies in the field of text prediction). The submission citeria is as below

        -Build a backend N-gram language model / algorithm based on a corpus of text provided by coursera
        -Incorporate the algorithm in a shiny app that can be tested by users
        -Build a pitch for this shiny text prediction app (this document you are looking at)


Data collection and initial inquiries
========================================================

Coursera provided the base corpus (text) files in order to base the language model. The corpus consisted of three files - blogs(800,000 lines), news(1,000,000 lines) and twitter(2,000,000 lines). These files can be are provided -> https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip. From this data a training set was created.


- The training set was creating by reading from the above corpus about 50,000 random paragraphs from the data set which resulted in assimilation of roughly 170,000 word combinations or ngrams.
- The text was preprocessed by removing numbers from the text as they do not contribute to prediction capability
- Other preprocessing steps like converting to lower cases, removal of punctuation was taken care of by implementing them individually using the "tm" package provided  by R.
- Tokenization of text was done by "RWeka" package used in association with "tm" package. RWeka package implements the Weka classification method fro machine learning which simplifies the tokenization process and boosts speed.
- Exploratory data analysis of this tokenized data revealed the existence of some special words which were either typos or intentionally written together(say to reduce the word count of a tweet.) They were not removed simply because they were very rare and wouldn't affect the implementation of the algorithm.



Approach to building Text Prediction Algorithm
========================================================

A 3-gram language model was decided to be used for the text prediction.This means that the next word will be predicted based on last 2 words. The following steps were followed:

- Tokenization into 1,2 and 3-grams by using tm and RWeka package to build the n-gram tables as a one time activity.
- The text prediction algorithm based on Katz back off model and MArkhoc's approach:
- Look for observed  3-grams, 2-grams and 1-gram(with most count) as prediction candidates.
- At each level, apply a discount(calculated from Good Turing Estimation) to extract probability mass from observed n-grams to accomodate unobserved n-grams
- Calculate the probabilities of the observed n-grams
- For each level of unobserved n-grams, apportion the extracted probability mass in the ratio of the probabilities of the observed n-grams. As we go down n-grams, the allocated probability becomes lesser.
- Consolidate the final table consisting of observed 3-grams (based on matching 3-gram hits) and unobserved 3-grams (based on matching 2 and 1-gram hits)
- List the top 3 entries based on probability. Those are the top 3 predicted words.


Resources       
===
Resources
Link to Shiny App:https://umang25.shinyapps.io/predictapp/. It has the instructions for getting text prediction.Please specify a minimum of 2 words for the input text.

my github link for all project - https://github.com/umang-25/CapstoneNLP

Resources that helped me with this project

- Stanford NLP course material (available on you tube)
- Documentation on tm package
- Katz Backoff model <- https://en.wikipedia.org/wiki/Katz%27s_back-off_model
- N-gram Implementation <- http://www.cs.cornell.edu/courses/cs4740/2014sp/lectures/smoothing+backoff.pdf
- Good-Turing Estimation <- https://en.wikipedia.org/wiki/Good%E2%80%93Turing_frequency_estimation


