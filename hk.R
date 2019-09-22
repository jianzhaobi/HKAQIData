#' Extract HongKong Air Quality Data
#' Author: Jianzhao Bi
#' Date: 9/21/2019

library(xml2)
library(rvest)
library(data.table)

# Site name and HTML
site.df <- data.frame(Name = c('CentralWestern', 'Eastern', 'KwunTong', 'ShamShuiPo', 
                               'KwaiChung', 'TsuenWan', 'TseungKwanO', 'YuenLong', 'TuenMun',
                               'TungChung', 'TaiPo', 'ShaTin', 'TapMun', 'CausewayBay', 
                               'Central', 'MongKok'),
                      HTML = c('http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration45fd.html?stationid=80',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentratione1a6.html?stationid=73',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentrationfb71.html?stationid=74',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentrationdb46.html?stationid=66',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration30e8.html?stationid=72',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration228e.html?stationid=77',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration0b35.html?stationid=83',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration1f2c.html?stationid=70',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration537c.html?stationid=82',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentrationf322.html?stationid=78',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration6e9c.html?stationid=69',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration2c5f.html?stationid=75',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration233a.html?stationid=76',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration5ca5.html?stationid=71',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentrationf9dd.html?stationid=79',
                               'http://www.aqhi.gov.hk/en/aqhi/past-24-hours-pollutant-concentration9c57.html?stationid=81'))

for (i in 1 : nrow(site.df)) {
  
  # --- Get the HK Air Quality data table --- #
  doc.html <- read_html(as.character(site.df$HTML[i]))
  new.html <- xml_find_all(doc.html, xpath = '///table[@class=\'tblNormal\']') 
  new.df <- html_table(new.html[[1]])
  names(new.df) <- c('DateTime', 'NO2', 'O3', 'SO2', 'CO', 'PM10', 'PM25')
  
  # --- Update the existing AQ data --- #
  old.file <- paste0('/home/jbi6/envi/HKAQIData/data/HongKong_', site.df$Name[i], '.csv') 
  
  if (file.exists(old.file)) {
    # Load existing table
    old.df <- fread(file = old.file)
    
    # Find and combine the data that do not exist in the old table
    idx <- !(new.df$DateTime %in% old.df$DateTime)
    add.df <- new.df[idx, ]
    old.df <- rbindlist(list(old.df, add.df))
  } else {
    old.df <- new.df
  }
  # Reorder
  old.df <- old.df[order(old.df$DateTime, decreasing = T), ] 
  
  # --- Write the updated table --- #
  write.csv(old.df, file = old.file, row.names = F)
  
}




