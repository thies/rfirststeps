# download data from Dropbox
# (I obtained return indices from Datastream, put them on Dropbox for exercise)
monthly <- read.csv("https://www.dropbox.com/s/y632b0nyu8bhbts/returns%20monthly.csv?dl=1", as.is=TRUE)
weekly <- read.csv("https://www.dropbox.com/s/uvp2bmlzpuogxve/returns%20weekly.csv?dl=1", as.is=TRUE)
quarterly <- read.csv("https://www.dropbox.com/s/riwlfc3tmkvzzbe/returns%20quarterly.csv?dl=1", as.is=TRUE)



# have a first look at data
head(monthly)
# convert date from string to proper dates
monthly$date <- as.Date(monthly$date)
weekly$date <- as.Date(weekly$date)

# sumstats
summary(monthly)
summary(weekly)

# Plot line graph
plot(monthly$date, monthly$sp500, type="l")
plot(weekly$date, weekly$sp500, type="l", col="red")


# calculate monthly returns
# (take difference of logs)
# We really should work with excess returns, 
# but I will skip this step in this example.
mret_sp500 <- diff(ts(log(monthly$sp500)))
mret_msft <- diff(ts(log(monthly$msft)))

plot(mret_sp500, mret_msft, col="red")

# estimate linear model, monthly
monthly_reg_msft <- lm(mret_msft~mret_sp500)
# have a look at coefficients of that model
summary(monthly_reg_msft)


# calculate weekly returns
# (take difference of logs)
wret_sp500 <- diff(ts(log(weekly$sp500)))
wret_msft <- diff(ts(log(weekly$msft)))

# estimate linear model, weekly
weekly_reg_msft <- lm(wret_msft~wret_sp500)
# have a look at coefficients of that model
summary(weekly_reg_msft)


# calculate quarterly returns
# (take difference of logs)
qret_sp500 <- diff(ts(log(quarterly$sp500)))
qret_msft <- diff(ts(log(quarterly$msft)))

# estimate linear model, quarterly
quarterly_reg_msft <- lm(qret_msft~qret_sp500)
# have a look at coefficients of that model
summary(quarterly_reg_msft)



# way  nicer tables can be seen with stargazer library
library(stargazer)
stargazer(quarterly_reg_msft, monthly_reg_msft, weekly_reg_msft, type="text")
