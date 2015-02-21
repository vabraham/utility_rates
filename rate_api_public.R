## Please note that you must replace the key below ("sample_key")with your own key for this script to work
## You can get your own key directly from http://www.data.gov/developers/apis
rm(list=ls())
install.packages("httr")
library(httr)

# Google maps Javascript AP1 v3
sample1 <- GET("https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA")
content(sample1)
# Or
add1 <- "1600 Amphitheatre Parkway, Mountain View, CA"
sample1 <- GET("https://maps.googleapis.com/maps/api/geocode/json", query = list(address = add1))
result1 <- content(sample1)
result1$results[[1]]$geometry$location$lat
result1$results[[1]]$geometry$location$lng

# Data.gov Utility Rates API
sample2 <- GET("http://api.data.gov/nrel/utility_rates/v3.json?api_key=sample_key&address=1600+Amphitheatre+Parkway,+Mountain+View,+CA")
content(sample2)
# Or
key <- "sample_key"
add1 <- "1600 Amphitheatre Parkway, Mountain View, CA"
sample2 <- GET("http://api.data.gov/nrel/utility_rates/v3.json", query = list(api_key = key, address = add1))
result2 <- content(sample2)
result2$outputs$utility_info[[1]]$utility_name
result2$outputs$residential

# Combining both the Google Maps API and the Data.gov API to get utility rates by city - preferred
google_url <- "https://maps.googleapis.com/maps/api/geocode/json"
gov_url <- "http://api.data.gov/nrel/utility_rates/v3.json"
geoCode <- function(address,verbose=FALSE) {
  r <- GET(google_url, query = list(address = address))
  stop_for_status(r)
  result1 <- content(r)
  
  if (!identical(result1$status, "OK")) {
    warning("Please input a valid US address.", call. = FALSE)
    return(c(NA,NA,NA,NA,NA,NA))
  }
  
  s <- GET(gov_url, query = list(api_key = "sample_key", lat = result1$results[[1]]$geometry$location$lat, lon = result1$results[[1]]$geometry$location$lng))
  stop_for_status(s)
  result2 <- content(s)
  
  if (result2$outputs$utility_name == "no data") {
    warning("Please input a valid US address.", call. = FALSE)
    return(c(NA,NA,NA,NA,NA,NA))
  }
  
  first <- result1$results[[1]]
  second <- result2$outputs
  list(
    lat = first$geometry$location$lat,
    lon = first$geometry$location$lng,
    type = first$geometry$location_type,
    address = first$formatted_address,
    utility = second$utility_info[[1]]$utility_name,
    residential_rate_kwh = second$residential
  )
}

# Test with different addresses
geoCode("San Francisco, CA")
geoCode("Beijing, China")