# =============================
# Example Script: Index estimation
#
# to be used in class as an intro to R coding
# htl24@cam.ac.uk
# ===============================


# Load additional libraries at start of script
library(stargazer)
# in case you don't have the Stargazer library installed, 
# you can add it to you system with this command: install.packages("stargazer")



# LOAD DATA
# get file from dropbox
temp <- tempfile()
download.file("https://www.dropbox.com/s/hzrxtl4j3mgqfju/Cambridge.csv.gz?dl=1", temp)
# load as data frame
sales <- read.csv(gzfile(temp), as.is=TRUE, header=FALSE)
# add meaningful column labels
colnames(sales) <- c("id","price","date","postcode","propertytype","new","estatetype","paon","saon","street","locality","town","district","county","PPDcategory","recordstatus")


# have a look at the data
head(sales)
summary(sales)
hist( log(sales$price), xlab="ln(price)", col="lightblue", main="Distribution of sales prices" )
barplot( table(sales$propertytype), xlab="D=Detached, F=Flat, S=Semidetached, T=Terraced, O=Other", col=c("red","green","blue","purple","orange"), main="Property types" )


# TIDYING UP
# clean up sales dates
sales$date <- gsub(" 00:00", "", sales$date)
sales$date <- strptime(sales$date,"%Y-%m-%d")
# create time dummy variables, monthly and yearly 
sales$month <- format(sales$date, format="%Y-%m")
sales$year <- as.factor(format(sales$date, format="%Y"))
# further data cleansing (very adhoc)
sales <- subset(sales, price < 5000000)
sales <- subset(sales, price > 10000)
sales <- subset(sales, propertytype != 'O')


# summary statistics
summary(sales$date)
summary(sales$price)
table(sales$propertytype)
table(sales$estatetype)
table(sales$new)


# FIRST ANALYSIS

#===============================
# Hedonic regressions

# model with monthly time effects
monthly <- lm(log(price) ~ propertytype + new + estatetype + month , data=sales)
yearly <- lm(log(price) ~ propertytype + new + estatetype + year , data=sales)


# regression tables 
stargazer(monthly, type="text")
stargazer(yearly, type="text")

# Maybe a bit more clear, omitting time effects
# column (1) shows estimates for hedonic control variables for monthly model, (2) for yearly model
stargazer(monthly, yearly, omit="month|year", type="text")


# convert the time dummy estimates to index figures 
ind <- monthly$coefficients[ grepl( 'month', names(monthly$coefficients) ) ]
ind <- exp(ind)*100
ind <- as.data.frame(ind)
colnames(ind) <- "indexmonthly"
ind$month <-row.names(ind)
ind <- rbind(c(100,"1995-01"), ind)
ind$month <- gsub("month", "",ind$month)
ind$date <- paste(ind$month, "-15", sep="")
ind$date <- as.Date(ind$date)
plot(ind$date, ind$indexmonthly, type="l", lwd=2, ylab="1995-01 = 100", xlab="Year")


ind2 <- yearly$coefficients[ grepl( 'year', names(yearly$coefficients) ) ]
ind2 <- exp(ind2)*100
ind2 <- as.data.frame(ind2)
colnames(ind2) <- "indexyearly"
ind2$year <-row.names(ind2)
ind2 <- rbind(c(100,"1995"), ind2)
ind2$year <- gsub("year", "",ind2$year)
ind2$date <- paste(ind2$year, "-07-15", sep="")
ind2$date <- as.Date(ind2$date)

indices <- merge(ind, ind2, by="date", all=TRUE)
indices$indexmonthly <- as.numeric(indices$indexmonthly)
indices$indexyearly <- as.numeric(indices$indexyearly)


# plot indices
plot(indices$date, ind$indexmonthly, type="l", lwd=2, ylab="1995-01 = 100", xlab="Year", col="red")
lines(indices$date[!is.na(indices$indexyearly)], indices$indexyearly[!is.na(indices$indexyearly)], lwd=2, col="blue") 


# having a closer look at the indices
summary(indices)

# returns
retm <- diff(ts(log(indices$indexmonthly)))
plot(retm, main="monthly returns, in logs")
rety <- diff(ts(log(indices$indexyearly[!is.na(indices$indexyearly)])))
plot(rety, main="yearly returns, in logs")

# sumstats for returns
summary(retm)
summary(rety)

# autocorrelation in returns?
acf(retm)
acf(rety)




