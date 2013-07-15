import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import LogisticRegression
from sklearn.cross_validation import cross_val_score
from sklearn.metrics import auc_score
import scipy.sparse as sp

train = pd.read_csv('train-utf8.csv')
test = pd.read_csv('test-utf8.csv')

'''
#########################################################################################################

vectorizer = CountVectorizer()
X_train = vectorizer.fit_transform(train.Comment)
X_test = vectorizer.transform(test.Comment)

NB = cross_val_score(MultinomialNB(), X_train, train.Insult, score_func = auc_score, cv = 5).mean()
LR = cross_val_score(LogisticRegression(), X_train, train.Insult, score_func = auc_score, cv = 5).mean()

print "Default: "
print "NB = " + str(NB) + ", LR + " + str(LR)

#########################################################################################################

vectorizer = CountVectorizer(ngram_range = (3,5), analyzer='char')
X_train = vectorizer.fit_transform(train.Comment)
X_test = vectorizer.transform(test.Comment)

NB = cross_val_score(MultinomialNB(), X_train, train.Insult, score_func = auc_score, cv = 5).mean()
LR = cross_val_score(LogisticRegression(), X_train, train.Insult, score_func = auc_score, cv = 5).mean()

print "CountVectorizer(ngram_range = (1,3), analyzer=word):"
print "NB = " + str(NB) + ", LR + " + str(LR)

#########################################################################################################

vectorizer = TfidfVectorizer(ngram_range = (3,5), analyzer='char', sublinear_tf=True)
X_train = vectorizer.fit_transform(train.Comment)
X_test = vectorizer.transform(test.Comment)

NB = cross_val_score(MultinomialNB(), X_train, train.Insult, score_func = auc_score, cv = 5).mean()
LR = cross_val_score(LogisticRegression(), X_train, train.Insult, score_func = auc_score, cv = 5).mean()

print "TfidfVectorizer(ngram_range = (1,3), analyzer=word, sublinear_tf=True:"
print "NB = " + str(NB) + ", LR + " + str(LR)

#########################################################################################################

vectorizer1 = TfidfVectorizer(ngram_range = (3,5), analyzer='char', sublinear_tf=True)
X_train1 = vectorizer1.fit_transform(train.Comment)
X_test1 = vectorizer1.transform(test.Comment)

vectorizer2 = TfidfVectorizer(ngram_range = (1,3), analyzer='word', sublinear_tf=True)
X_train2 = vectorizer2.fit_transform(train.Comment)
X_test2 = vectorizer2.transform(test.Comment)

X_train = sp.hstack([X_train1, X_train2])
X_test = sp.hstack([X_test1, X_test2])

NB = cross_val_score(MultinomialNB(alpha = 0.5), X_train, train.Insult, score_func = auc_score, cv = 5).mean()
LR = cross_val_score(LogisticRegression(C=3), X_train, train.Insult, score_func = auc_score, cv = 5).mean()

print "Tfidf, chars + words, weights on models:"
print "NB = " + str(NB) + ", LR + " + str(LR)

#########################################################################################################

'''
vectorizer = CountVectorizer()
X_train = vectorizer.fit_transform(train.Comment)
X_test = vectorizer.transform(test.Comment)

NB = cross_val_score(MultinomialNB(alpha=0.5), X_train, train.Insult, score_func = auc_score, cv = 5).mean()
LR = cross_val_score(LogisticRegression(C=3), X_train, train.Insult, score_func = auc_score, cv = 5).mean()

print "Default with regularization weights: "
print "NB = " + str(NB) + ", LR + " + str(LR)

model = MultinomialNB(alpha = 0.5).fit(X_train, list(train.Insult))
predictions = model.predict_proba(X_test)[:,1]

submission = pd.DataFrame({'id': test.id, 'insult': predictions})
submission.to_csv('final_submission.csv', index=False)

