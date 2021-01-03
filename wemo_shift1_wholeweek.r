library(tidyverse)
library(forecast)
library(timetk)
library(Metrics)
library(lubridate)
library(sweep)
library(caret) # used for avNNet
library(zoo)

# Read in data
wemo.df <- read.csv("Downloads/Data_Jan_to_Aug.csv")
wemo.df$service_hour=as.POSIXct(paste(wemo.df$service_hour_date, wemo.df$shift), format="%Y-%m-%d %H:%M:%S")

# Filter area & time (days without 3 shifts)
wemo.df.new <- wemo.df%>%
  filter(admin_town_zh != "三重區" & admin_town_zh != "超出營運範圍"& admin_town_zh != "泰山區"
         & admin_town_zh != "五股區" & admin_town_zh != "土城區" & admin_town_zh != "樹林區" & 
           admin_town_zh != "汐止區" & service_hour_date != "2020-01-31" & service_hour_date != "2020-08-31")

# Derived variable (Weekend or weekday)
wemo.df.new$weekday<-weekdays(wemo.df.new$service_hour)
wemo.df.new$weekend_or_weekday<-ifelse(wemo.df.new$weekday=="Saturday" | wemo.df.new$weekday == "Sunday", 1, 0)

# Change type to character
wemo.df.new$service_hour_date <- as.character(wemo.df.new$service_hour_date)

# Filter columns
wemo.df.new <- wemo.df.new %>% 
  select(admin_town_en, sum_offline_scooter, service_hour_date, shift, weekend_or_weekday)

# Plot time series for offline scooters (whole week & no shift)
wemo.df.new %>%
  group_by(admin_town_en)%>%
  ggplot(aes(as.Date(service_hour_date), sum_offline_scooter, color=admin_town_en))+
  geom_line(size=.4)+
  guides(color=F)+
  facet_wrap(~admin_town_en, nrow=5, scales='free_y')+
  labs(x='', title='Time series for offline scooters')

# Shift1 + Whole week
shift_1 <- wemo.df.new%>%
  filter(shift == '00:00:00')

### Create train/validation sets
# Whole week
train_s1 <- shift_1%>%
  filter(service_hour_date <= as.Date('2020-07-31'))
test_s1 <- shift_1%>%
  filter(service_hour_date > as.Date('2020-07-31'))

#####################
# Naive
#set up naive for comparison. final date training period sales: 2020-07-31
naive_pred_s1 <- train_s1%>%
  mutate(service_hour_date = as.Date(service_hour_date))%>%
  group_by(admin_town_en)%>%
  filter(service_hour_date == last(service_hour_date))%>%
  pull(sum_offline_scooter)

naive_towns_s1 <- train_s1%>%
  mutate(service_hour_date = as.Date(service_hour_date))%>%
  group_by(admin_town_en)%>%
  filter(service_hour_date == last(service_hour_date))%>%
  pull(admin_town_en)

#create a 'naive df' of final value repeated 30 days forward
naive_df_s1 <- data.frame(forecast = rep(naive_pred_s1, 30),
                          admin_town_en = rep(naive_towns_s1, 30))
naive_s1 <- naive_df_s1%>%
  group_by(admin_town_en)%>%
  mutate(service_hour_date = seq.Date(as.Date('2020-08-01'),
                                      by='day', length.out = 30))

naive_s1$service_hour_date <- as.character(naive_s1$service_hour_date)

#Join test set
naive_forecast_date <- naive_s1 %>%
  inner_join(test_s1, by = c('service_hour_date', 'admin_town_en'))


# label your model forecasts for later visualization
naive_forecast_date <- naive_forecast_date %>%
  mutate(model = 'naive')

# #calculate forecast error i
# naive_forecast_date <- naive_forecast_date %>%
#   mutate(error = forecast-sum_offline_scooter)

#plot error series.
naive_forecast_date%>%
  ggplot(aes(service_hour_date, error, color=admin_town_en, group=admin_town_en))+
  geom_line()+
  guides(color=F)+
  facet_wrap(~admin_town_en, nrow=5)

#CHECK ACCURACY ON TEST SET: RMSE 231.9899
naive_forecast_accuracy <- forecast::accuracy(naive_forecast_date$forecast, naive_forecast_date$sum_offline_scooter)
naive_forecast_date$forecast


# Calculate each RMSE
naive_forecast_date%>%
  group_by(admin_town_en)%>%
  summarize(rm = rmse(sum_offline_scooter,forecast))

#Train fitted
  dist_train_naive <- data.frame(admin_town_en = train_s1$admin_town_en, 
                                 sum_offline_scooter = train_s1$sum_offline_scooter, 
                                 service_hour_date = train_s1$service_hour_date, 
                                 shift = train_s1$shift, 
                                 weekend_or_weekday = train_s1$weekend_or_weekday)
  
  dist_train_naive$forecast[2:3458] <- train_s1$sum_offline_scooter[0:3457]
  
  dist_train_naive <- dist_train_naive%>%
    group_by(admin_town_en)%>%
    mutate(forecast = ifelse(service_hour_date == first(service_hour_date), NA, forecast ))
  
  # label your model forecasts for later visualization
  dist_train_naive <- dist_train_naive %>%
    mutate(model = "naive")
  
  dist_train_naive <- as.data.frame(dist_train_naive)
  

  #rbind to one dataframe
  full_df_train <- data.frame()
  full_df_train <- rbind(dist_train_naive,full_df_train)


################### BUILD TS OBJECTS
# CONVERT TO DATE GROUP AND THEN NEST EACH MATERIAL INTO LIST COLUMNS

nest_s1 <- train_s1%>%
  mutate(service_hour_date = ymd(service_hour_date))%>%
  group_by(admin_town_en)%>%
  select(-admin_town_en, sum_offline_scooter)%>%
  nest(.key= 'dem_df')


### Time Series Nest for [shift 1 + whole week] ###
# FOR EACH LIST COLUMN, CONVERT IT TO TIME SERIES OBJECT
nest_s1_ts <- nest_s1 %>%
  mutate(dem_df = 
           map(.x = dem_df,
               .f = tk_ts,
               select = sum_offline_scooter, #select the outcome col
               start= c(2020,31), #Jan 31th 2011 (needs a check!!!)
               #end = c(2020,210),
               deltat= 1/365)) #daily data


#####################
# MOVING AVERAGE
mv_models <- nest_s1_ts %>%
  mutate(mv_fit = map(.x=dem_df,
                      .f = function(x) rollmean(x, k = 12, align = "right")))

mv_forecast <- mv_models %>%
  mutate(fcast = map(mv_fit,
                     forecast,
                     h=30))%>%
  mutate(swp = map(fcast, sw_sweep, fitted=FALSE))%>%
  unnest(swp)%>%
  filter(key == 'forecast')%>%
  mutate(service_hour_date = seq(from = as.Date('2020-08-01'), by='day', length.out = 30))%>%
  select(admin_town_en, service_hour_date, sum_offline_scooter)

mv_forecast$service_hour_date <- as.character(mv_forecast$service_hour_date)

# join with actual values in validation
mv_forecast_date <- mv_forecast %>%
  left_join(test_s1, by = c('service_hour_date'='service_hour_date', 'admin_town_en'))

# label your model forecasts for later visualization
mv_forecast_date <- mv_forecast_date %>%
  mutate(model = 'mv')

# CHECK ACCURACY ON TEST SET: RMSE 236.952
mv_forecast_accuracy <- forecast::accuracy(mv_forecast_date$sum_offline_scooter.y, mv_forecast_date$sum_offline_scooter.x)
mv_forecast_date$sum_offline_scooter.y

# join with actual values in train

for (i in 1:19) {
  #get fitted value
  mv_fitted <- data.frame(mv_models$mv_fit[[i]])
  mv_fitted$admin_town_en <- mv_models$admin_town_en[i]
  mv_fitted
  
  # conbine fitted and actual
  dist_train <- train_s1%>%
    filter(admin_town_en == mv_fitted$admin_town_en[i])
  dist_train$forecast <- NA
  dist_train[12:182,]$forecast <- mv_fitted$sum_offline_scooter
  
  # label your model forecasts for later visualization
  dist_train <- dist_train %>%
    mutate(model = "mv")
  
  #rbind to one dataframe
  full_df_train <- rbind(dist_train,full_df_train)
}

#####################
# AUTOARIMA. 
ar_models <- nest_s1_ts %>%
  mutate(ar_fit = map(.x=dem_df,
                      .f = auto.arima))

### TIDYING UP
# FORECAST in testing for 30 days
ar_forecast <- ar_models %>%
  mutate(fcast = map(ar_fit,
                     forecast,
                     h=30))%>%
  mutate(swp = map(fcast, sw_sweep, fitted=FALSE))%>%
  unnest(swp)%>%
  filter(key == 'forecast')%>%
  mutate(service_hour_date = seq(from = as.Date('2020-08-01'), by='day', length.out = 30))%>%
  select(admin_town_en, service_hour_date, sum_offline_scooter)

ar_forecast$service_hour_date <- as.character(ar_forecast$service_hour_date)

ar_forecast
# join with actual values in validation
ar_forecast_date <- ar_forecast %>%
  left_join(test_s1, by = c('service_hour_date'='service_hour_date', 'admin_town_en'))


# label your model forecasts for later visualization
ar_forecast_date <- ar_forecast_date %>%
  mutate(model = 'arima')

# CHECK ACCURACY ON TEST SET. x is pred, y is actual. RMSE 232.4308
ar_forecast_accuracy <- forecast::accuracy(ar_forecast_date$sum_offline_scooter.y, ar_forecast_date$sum_offline_scooter.x)


# join with actual values in train
for (i in 1:19) {
  #get fitted value
  ar_fitted <- data.frame(ar_models[[3]][[i]]$fitted)
  ar_fitted$admin_town_en <- ar_models$admin_town_en[i]
  
  # conbine fitted and actual
  dist_train <- train_s1%>%
    filter(admin_town_en == ar_fitted$admin_town_en[i])
  dist_train$forecast <- ar_fitted$x
  
  # label your model forecasts for later visualization
  dist_train <- dist_train %>%
    mutate(model = "ar")
  
  #rbind to one dataframe
  full_df_train <- rbind(dist_train,full_df_train)
}


# plot forecasts to verify nothing insane happened
ar_forecast %>%
  group_by(admin_town_en)%>%
  ggplot(aes(service_hour_date, sum_offline_scooter, color=admin_town_en, group=admin_town_en))+
  geom_line(size=1)+
  labs(x='', title='ARIMA plot for [shift1] in [whole week]')



#####################
# LINEAR REGRESSION FORECAST
## FORECAST in testing for 30 days
lm_models <- nest_s1_ts %>%
  mutate(lm_fit = map(.x=dem_df,
                      .f = function(x) tslm(x ~ trend)))

lm_forecast <- lm_models %>%
  mutate(fcast = map(lm_fit,
                     forecast,
                     h=30))%>%
  mutate(swp = map(fcast, sw_sweep, fitted=FALSE))%>%
  unnest(swp)%>%
  filter(key == 'forecast')%>%
  mutate(service_hour_date = seq(from = as.Date('2020-08-01'), by='day', length.out = 30))%>%
  select(admin_town_en, service_hour_date, value)

lm_forecast$service_hour_date <- as.character(lm_forecast$service_hour_date)

# join with actual values in validation
lm_forecast_date <- lm_forecast %>%
  left_join(test_s1, by = c('service_hour_date'='service_hour_date', 'admin_town_en'))

# label your model forecasts for later visualization
lm_forecast_date <- lm_forecast_date %>%
  mutate(model = 'lm')

# CHECK ACCURACY ON TEST SET: RMSE 296.1717
lm_forecast_accuracy <- forecast::accuracy(lm_forecast_date$sum_offline_scooter, lm_forecast_date$value) #sum_offline_scooter = actual, value = forecast value

# join with actual values in train
for (i in 1:19) {
  #get fitted value
  lm_fitted <- data.frame(lm_models[[3]][[i]]$fitted.values)
  lm_fitted$admin_town_en <- lm_models$admin_town_en[i]
  
  # conbine fitted and actual
  dist_train <- train_s1%>%
    filter(admin_town_en == lm_fitted$admin_town_en[i])
  dist_train$forecast <- lm_fitted$lm_models..3....i...fitted.values
  
  # label your model forecasts for later visualization
  dist_train <- dist_train %>%
    mutate(model = "lm")
  dist_train$forecast <- as.numeric(dist_train$forecast)
  
  #rbind to one dataframe
  full_df_train <- rbind(dist_train, full_df_train)
}




################# 
# ETS FORECAST
ets_models <- nest_s1_ts %>%
  mutate(ets_fit = map(.x=dem_df,
                       .f = ets))

ets_forecast <- ets_models %>%
  mutate(fcast = map(ets_fit,
                     forecast,
                     h=30))%>%
  mutate(swp = map(fcast, sw_sweep, fitted=FALSE))%>%
  unnest(swp)%>%
  filter(key == 'forecast')%>%
  mutate(service_hour_date = seq(from = as.Date('2020-08-01'), by='day', length.out = 30))%>%
  select(admin_town_en, service_hour_date, sum_offline_scooter)

ets_forecast$service_hour_date <- as.character(ets_forecast$service_hour_date)

#join with actual values in validation
ets_forecast_date <- ets_forecast %>%
  left_join(test_s1, by = c('service_hour_date'='service_hour_date', 'admin_town_en'))

#label your model forecasts for later visualization
ets_forecast_date <- ets_forecast_date %>%
  mutate(model = 'ets')

#CHECK ACCURACY ON TEST SET. x is pred, y is actual. RMSE 626.9194
ets_forecast_accuracy <- forecast::accuracy(ets_forecast_date$sum_offline_scooter.y, ets_forecast_date$sum_offline_scooter.x)


# join with actual values in train
for (i in 1:19) {
  #get fitted value
  ets_fitted <- data.frame(ets_models[[3]][[i]]$fitted)
  ets_fitted$admin_town_en <- ets_models$admin_town_en[i]
  
  # conbine fitted and actual
  dist_train <- train_s1%>%
    filter(admin_town_en == ets_fitted$admin_town_en[i])
  dist_train$forecast <- ets_fitted$y
  
  # label your model forecasts for later visualization
  dist_train <- dist_train %>%
    mutate(model = "ets")

  #rbind to one dataframe
  full_df_train <- rbind(dist_train,full_df_train)
}


################# 
# Seasonal NAIVE FORECAST

#Valid  forecast
dist_valid_snaive <- data.frame(admin_town_en = test_s1$admin_town_en, 
                                sum_offline_scooter = test_s1$sum_offline_scooter, 
                                service_hour_date = test_s1$service_hour_date, 
                                shift = test_s1$shift, 
                                weekend_or_weekday = test_s1$weekend_or_weekday)

dist_valid_snaive$sum_offline_scooter[8:570] <- test_s1$sum_offline_scooter[0:563]

# dist_valid_snaive <- dist_valid_snaive%>%
#   group_by(admin_town_en)%>%
#   mutate(sum_offline_scooter = ifelse(as.Date(service_hour_date) < as.Date('2020-08-08'),  NA, sum_offline_scooter ))

# label your model forecasts for later visualization
dist_valid_snaive <- dist_valid_snaive %>%
  mutate(model = "snaive")

dist_valid_snaive <- as.data.frame(dist_valid_snaive)

snaive_forecast_date <- dist_valid_snaive %>%
  select(admin_town_en, service_hour_date, sum_offline_scooter, model)


#join with actual values in validation
snaive_forecast_date <- snaive_forecast_date %>%
  left_join(test_s1, by = c('service_hour_date'='service_hour_date', 'admin_town_en'))

# CHECK ACCURACY ON TEST SET. x is pred, y is actual. RMSE 363.9651
snaive_forecast_accuracy <- forecast::accuracy(snaive_forecast_date$sum_offline_scooter.y, snaive_forecast_date$forecast)


#Train fitted
dist_train_snaive <- data.frame(admin_town_en = train_s1$admin_town_en, 
                               sum_offline_scooter = train_s1$sum_offline_scooter, 
                               service_hour_date = train_s1$service_hour_date, 
                               shift = train_s1$shift, 
                               weekend_or_weekday = train_s1$weekend_or_weekday)

dist_train_snaive$forecast[8:3458] <- train_s1$sum_offline_scooter[0:3451]

dist_train_snaive <- dist_train_snaive%>%
  group_by(admin_town_en)%>%
  mutate(forecast = ifelse(as.Date(service_hour_date) < as.Date('2020-02-08'),  NA, forecast ))

# label your model forecasts for later visualization
dist_train_snaive <- dist_train_snaive %>%
  mutate(model = "snaive")

dist_train_snaive <- as.data.frame(dist_train_snaive)


#rbind to one dataframe
full_df_train <- rbind(dist_train_snaive,full_df_train)


################# 
#Nerual Net
nn_models <- nest_s1_ts %>%
  mutate(nn_fit = map(.x=dem_df,
                      .f = function(x) nnetar(x, repeats = 5, size=10)))

summary(nn_models)
nn_forecast <- nn_models %>%
  mutate(fcast = map(nn_fit,
                     forecast,
                     h=30))%>%
  mutate(swp = map(fcast, sw_sweep, fitted=FALSE))%>%
  unnest(swp)%>%
  filter(key == 'forecast')%>%
  mutate(service_hour_date = seq(from = as.Date('2020-08-01'), by='day', length.out = 30))%>%
  select(admin_town_en, service_hour_date, sum_offline_scooter)

nn_forecast$service_hour_date <- as.character(nn_forecast$service_hour_date)

#join with actual values in validation
nn_forecast_date <- nn_forecast %>%
  left_join(test_s1, by = c('service_hour_date'='service_hour_date', 'admin_town_en'))

#label your model forecasts for later visualization
nn_forecast_date <- nn_forecast_date %>%
  mutate(model = 'nn')

#CHECK ACCURACY ON TEST SET. x is pred, y is actual. RMSE 261.4412
nn_forecast_accuracy <- forecast::accuracy(nn_forecast_date$sum_offline_scooter.y, nn_forecast_date$sum_offline_scooter.x)


############ Combine all into one long DF
# LOOK AT PREDICTION ERROR FOR ALL MODELS

# change column names from naive model to match others. forecast is pred, sum_offline_scooter is actual
naive_forecast_date <- naive_forecast_date %>%
  mutate(sum_offline_scooter.x = forecast,
         sum_offline_scooter.y = sum_offline_scooter,
         value = NULL,
         sum_offline_scooter = NULL)

# change column names from lm model to match others. Value is pred, sum_offline_scooter is actual
lm_forecast_date <- lm_forecast_date %>%
  mutate(sum_offline_scooter.x = value,
         sum_offline_scooter.y = sum_offline_scooter,
         value = NULL,
         sum_offline_scooter = NULL)


# Combine all models into one long DF
class(lm_forecast_date)
naive_forecast_date
class(snaive_forecast_date)


full_df <- rbind(lm_forecast_date, 
                 ar_forecast_date,
                 ets_forecast_date,
                 #snaive_forecast_date,
                 naive_forecast_date,
                 nn_forecast_date,
                 mv_forecast_date)

full_df <- as.data.frame(full_df)
full_df <- full_df[,-8]

full_df <- rbind(full_df, snaive_forecast_date)

full_df <- full_df%>%
  mutate(error = sum_offline_scooter.x - sum_offline_scooter.y)

# Conclude from the visual (error in all models)
full_df%>%
  ggplot(aes(service_hour_date, error, color=model, group=model))+
  geom_line()+
  ylim(-1500,3000)+
  facet_wrap(~admin_town_en, ncol =2, scale='free_y')+
  labs(x='', title='Residuals for offline scooters in [shift1] on testing data in [whole week]')

# Print out accuracy of each model
naive_forecast_accuracy
snaive_forecast_accuracy
mv_forecast_accuracy
lm_forecast_accuracy
ets_forecast_accuracy
ar_forecast_accuracy
nn_forecast_accuracy

