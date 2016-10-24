##' Retrieve salary values (if present) from the Indeed API.
##'
##' Salary figures are not explicity returned by the Indeed API (see
##' \code{jobSearch} and \code{jobkeySearch}). \code{getSalary} tries to
##' overcome this by scraping any salary figures from the job description page
##' (the results.url column from the \code{jobSearch} or \code{jobkeySearch}
##' output). Note that it's quite common for job descriptions to not include any
##' salary data, which will return NA.
##'
##'
##' @param url (string). The url of the job description page. Required. No
##'   default.
##' @param currency (string). Currency of the salary. The default is USD ($).
##'   Currently, the only supported currencies are USD, GBP and EUR.
##'
##' @return A dataframe is returned, consisting of:
##'   status: Job status (contract, permanent, temporary);
##'   period: Salary period (day, week, month, year);
##'   currency: The currency passed as an argument;
##'   minSal: If a range is detected (e.g. $40,000 - $60,000), then this is the
##'   lower value. If no range is dectected, then minSal and maxSal will equal this value;
##'   maxSal: If a range is detected (e.g. $40,000 - $60,000), then this is the
##'   higher value. If no range is dectected, then minSal and maxSal will equal this value.
##'
##' @examples
##' \dontrun{
##' # search for data scientist jobs in Dublin, Ireland (10 jobs returned)
##' jobs <- searchJobs(publisher="123445678", query="data+scientist",
##'                    country = "ie", location = "dublin")
##'
##' # retrieve salary for the first job posted
##' getSalary(jobs$results.url[1],"GBP")
##'
##' # retrieve salary for all jobs
##' lapply(jobs$results.url,function(x){getSalary(x,"GBP")})
##'
##' }
##'

getSalary=function(url, currency=c("USD","GBP","EUR")){

  kFlag <- FALSE
  type <- match.arg(currency)
  output <- data.frame(status="unknown", period="unknown", currency= currency,
                       minSal=NA, maxSal=NA)
  page <- xml2::read_html(url)
  text <- rvest::html_nodes(page,"#job_header+ div") %>% rvest::html_text()
  print(text)
  if(length(text)==0)
    return(output)

  if(grepl(" Contract",text)){
    output$status <- "Contract"
  }else if(grepl(" Temporary",text)){
    output$status <- "Temporary"
  }else if(grepl(" Permanent",text)){
    output$status <- "Permanent"}

  text <- switch(type,
                 USD=strsplit(text,"$"),
                 GBP=strsplit(text,"\uA3"),
                 EUR=strsplit(text,"\u20AC"))

  text <- text[[1]]
  len <- length(text)

  if(len==1 | len==4 | len>5){
    return(output)
  }else if(len==2){
    output$minSal <- output$maxSal <- gsub( " .*$", "", text[2] )
  }else{
    output$minSal <- output$maxSal <- gsub( " .*$", "", text[len-1] )
    output$maxSal <- output$maxSal <- gsub( " .*$", "", text[len] )
  }

  if(grepl("year",text[len])){
    output$period <- "year"
  }else if(grepl("month",text[len])){
    output$period <- "month"
  }else if(grepl("week",text[len])){
    output$period <- "week"
  }else if(grepl("day",text[len])){
    output$period <- "day"
  }

  if(grepl("K", output$minSal)){
    output$minSal <- gsub("K.*$","",output$minSal)
    kFlag = TRUE
    if(grepl("-", output$minSal)){
      output$maxSal <- gsub(".*-","",output$minSal)
      output$minSal <- gsub("-.*$","",output$minSal)
    }
  }

  if(grepl("K", output$maxSal)){
    kFlag = TRUE
    output$maxSal <- gsub("K.*$","",output$maxSal)
  }

  output[c("minSal","maxSal")] <- as.numeric(gsub(",","",output[c("minSal","maxSal")]))

  if(kFlag)
    output[c("minSal","maxSal")] <- output[c("minSal","maxSal")] * 1000

  return(output)
}
