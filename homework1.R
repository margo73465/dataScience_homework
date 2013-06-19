library(ggplot2)
#Doesn't work if the files aren't in the working directory
#Read in data files
apos <- read.csv('apos.txt', header=T)
cuisine <- read.csv('Cuisine.txt', header=T)

#Find unique elements without blanks
unique_apos <- uniquec(apos)
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