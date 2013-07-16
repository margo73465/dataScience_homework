# Salary prediction using linear regression

# Set the working directory
setwd('~/Documents/data_science/homework/linreg_assignment/')

# Declare the MAE function
mae <- function(x,y)
{
  return(mean(abs(x-y)))
}

# Import smallest training set
alltrain <- read.csv("train.csv")

# Generate random partitions of full training set into training and testing sections
set.seed(5)
alltrain$fold <- sample(1:10, nrow(alltrain), replace=TRUE)
train <- subset(alltrain, fold != 1)
test <- subset(alltrain, fold == 1)

# Extremely simple linear model to get a sense of what error level to beat
expression <- log(SalaryNormalized) ~ 1
model <- lm(expression, data = train)
summary(model)
# This function returns the error (MAE) of model.expression for a specific fold of the training data
error_from_fold <- function(n, expression){
  model <- lm(expression, data=subset(alltrain, fold != n))
  test <- subset(alltrain, fold == n)
  error <- mae(exp(predict(model,test)),test$SalaryNormalized)
  return(error)
}
# Using sapply we can find the average error across all folds of the data
mean(sapply(1:10, error_from_fold, expression))
# MAE across folds = 11285.22

# In order to get the Location_Tree.csv into a useful format I used the following:
# First, I replaced ~ with ", " because I think the quoting helped with some weird issues:

# cat Location_Tree.csv | sed 's/~/", "/g' > New_Location_Tree.csv

# Since the number of fields in each row was not constant I also created this file, which 
# contains the most precise (last) location listed in each row:

# cat New_Location_Tree.csv | awk -F ", " '{ print $(NF) }' > Last_Location_Col.csv

# I then read both of these data files into R
location.tree <- read.csv('New_Location_Tree.csv', header=F, col.names = c("Country", "Region", "City","V4","V5","V6","V7"))
last.location.col <- read.csv('Last_Location_Col.csv',header=F)
# I used these commands to set up a LocationNormalized column in the location.tree data frame for
# easy merging:
location.tree$V7 <- NULL
location.tree <- cbind(location.tree, last.location.col)
colnames(location.tree)[7] <- "LocationNormalized"

# Some locations are listed 2x, which causes there to be duplicate listings after merging, to avoid
# this I reduced the location.tree to unique locations based on "LocationNormalized"
location.tree <- subset(location.tree, !duplicated(LocationNormalized))

# Some further cleaning on the Region column of location.tree:
location.tree[grep(" Channel Isles", location.tree$Region), "Region" ] <- " Channel Islands"
location.tree[grep(" E Midlands", location.tree$Region), "Region" ] <- " East Midlands"
location.tree[grep(" E Mids", location.tree$Region), "Region" ] <- " East Midlands"
location.tree[grep(" East Mids", location.tree$Region), "Region" ] <- " East Midlands"
location.tree[grep(" N E England", location.tree$Region), "Region" ] <- " North East England"
location.tree[grep(" NE England", location.tree$Region), "Region" ] <- " North East England"
location.tree[grep(" NW England", location.tree$Region), "Region" ] <- " North West England"
location.tree[grep(" SW England", location.tree$Region), "Region" ] <- " South West England"
location.tree[grep(" SE England", location.tree$Region), "Region" ] <- " South East England"
location.tree[grep(" W Midlands", location.tree$Region), "Region" ] <- " West Midlands"
location.tree[grep(" West Mids", location.tree$Region), "Region" ] <- " West Midlands"
location.tree[grep(" Yorkshire And The Humber", location.tree$Region), "Region" ] <- " Yorkshire and Humberside"
location.tree[grep(" Yorkshire", location.tree$Region), "Region" ] <- " Yorkshire and Humberside"
location.tree[grep(" Yorks", location.tree$Region), "Region" ] <- " Yorkshire and Humberside"
location.tree$Region <- factor(location.tree$Region)

# Merge:
alltrain <- merge(alltrain, location.tree)
train <- subset(alltrain, fold != 1)
test <- subset(alltrain, fold == 1)

# Now to try some more complex models: 

# I started with the simple categorical variables ContractType and ContractTime
expression = log(SalaryNormalized) ~ ContractType + ContractTime
model <- lm(expression, data = train)
summary(model)
# R-squared = 0.09741
mean(sapply(1:10, error_from_fold, expression))
# MAE across folds = 10586.31

# Adding in the Category and Region:
expression = log(SalaryNormalized) ~ ContractType + ContractTime + Category + Region
model <- lm(expression, data = train)
summary(model)
# R-squared = 0.2846
mean(sapply(1:10, error_from_fold, expression))
# MAE across folds = 9474.879

# Load in real test data, make final model using all training data, and make predictions
realtest <- read.csv("test.csv")
realtest <- merge(realtest, location.tree)
unknown_category_id <- which(!(realtest$Category %in% levels(alltrain$Category))) #
realtest$Category[unknown_category_id] <- as.factor("Other/General Jobs")
finalmodel <- lm(expression, data=alltrain)
predictions <- predict(finalmodel, realtest)

# Put the submission together and write it to a file
submission <- data.frame(Id=realtest$Id, Salary=exp(predictions))
write.csv(submission, "MargoSmith_submission.csv", row.names=FALSE)

# I checked out glmnet but didn't get too far...
library(glmnet)
model <- cv.glmnet(model.matrix(~train$ContractType),matrix(train$SalaryNormalized))
as.vector(predict(model, model.matrix(~test$ContractType), s="lambda.min"))
# I also tried to load in bigger data sets and nearly broke my computer.
