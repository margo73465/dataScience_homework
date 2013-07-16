library(ggplot2)
setwd('~/Documents/data_science/homework/ggplot_assignment/')

#Read in data files
#Creating a usable file from the raw downloaded data was tricky because some apostrophes
#had been entered as quotation marks. Entering the following in the command line will
#change them to apostrophes and create a nice file called apos.txt
#cat WebExtract.txt | sed -E s/\([[:alpha:]]\)\"\([[:alpha:]]\)/\\1\'\\2/g > apos.txt
apos <- read.csv('apos.txt', header=T)
cuisine <- read.csv('Cuisine.txt', header=T)

#Find unique elements without blanks
unique_apos <- unique(apos)
unique_apos <- na.omit(unique_apos)

#Merge the data frames and find aggregate means for each cuisine
apos_cuisine <- merge(unique_apos, cuisine)
cuisine_mean <- aggregate(apos_cuisine$SCORE, by = list(apos_cuisine$CODEDESC), mean)
names(cuisine_mean) <- c("CUISINE","MEAN")

#Plot and save
png('cuisine_mean.png', width = 1000, height = 1000)
p <- ggplot(cuisine_mean, aes(x = reorder(CUISINE,-MEAN), y = MEAN)) + geom_bar(stat='identity') + coord_flip()
p
dev.off()