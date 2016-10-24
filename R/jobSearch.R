##' Perform simple job search
##'
##' Performs a simple job search call to the Indeed API.
##'
##' @param publisher (string) Publisher ID (e.g. "901314124155123"), which is assigned when you register as a publisher. No default. (required)
##' @param query (string) Job query. For simple queries, words are seperated by a plus sign e.g. "data+scientist". For more advanced queries, use the adavanced search \url{http://www.indeed.co.uk/advanced_search} and check the corresponding value of q in the url. No default. (required)
##' @param country (string). Specifies the country of the job search. The default is "us", which corresponds to the USA.
##' @param location (string). Specific area within country over which you want to perform the job search. Accepts postal codes or a  "city, state/province/region" combination (see \url{https://ads.indeed.com/jobroll/xmlfeed} for country specific codes). Default is "", which returns jobs for the whole country.
##' @param radius (integer). Allowable distance in miles from search location ("as the crow flies"). Default is 25.
##' @param sort (string). Sort by relevance or date. Default is "relevance".
##' @param start (integer). Start results at this result number. Default is 0.
##' @param limit (integer). Maximum number of results returned per query (1-25). Default is 10.
##' @param all (boolean). Single API calls are limited to 25 jobs. To return all jobs in a single data frame, then set all = TRUE (this will override the start and limit arguments). Default is all = FALSE.
##' @param latlong (integer). If latlong=1, search returns latitude and longitude information for each job result. Default is 0.
##' @param fromAge (integer). Number of days back to search. Default is currently unknown to me.
##' @param st (string). Site type. To show only jobs from job boards use "jobsite". For jobs from direct employer websites, use "employer". Default is "" i.e. show all jobs.
##' @param jt (string). Job type. Allowed values: "fulltime", "parttime", "contract", "internship", "temporary". Default is "" i.e. no job type distinction within search.
##' @param filter (integer). Filter duplicate results. 0 turns off duplicate job filtering. Default is 1.
##' @param userip (string). The IP number of the end-user to whom the job results will be displayed. The default value is "1.2.3.4", which should cover most cases. Unless you use the wrapper for some front end work, there's no need to alter the default value.
##' @param version (integer). Specifies the version of the API you wish to use. All publishers should be using version 2. Currently available versions are 1 and 2. Default is 2.
##' @param userAgent (string). The User-Agent (browser) of the end-user to whom the job results will be displayed. The default value is "Mozilla/\%2F4.0\%28Firefox\%29", which should cover most cases. Unless you use the wrapper for some front end work, there's no need to alter the default value.
##' @param callback (string).  The name of a javascript function to use as a callback to which the results of the search are passed. For security reasons, the callback name is restricted letters, numbers, and the underscore character. The default value is "", which should cover most cases. Unless you use the wrapper for some front end work, there's no need to alter the default value.
##' @param highlight (integer). Setting this value to 1 will bold terms in the snippet that are also present in q. Default is 0.
##' @param chnl (string). Channel Name. Group API requests to a specific channel.
##'
##' @return The output is converted from its JSON format to a data frame.
##'
##' @examples
##' \dontrun{
##' # search for data scientist jobs in Dublin, Ireland (10 jobs returned)
##' searchJobs(publisher="123445678", query="data+scientist",
##'            country = "ie", location = "dublin")
##'
##' # search for all data scientist jobs in Dublin, Ireland, sorted by date
##' searchJobs(publisher="123445678", query="data+scientist",
##'            country = "ie", location = "dublin", all = TRUE, sort="date")
##'
##' }
##'

jobSearch <- function(publisher, query, country = "us", location="", radius=25,
                       sort=c("relevance","date"), start=0, limit = 10, all = FALSE,
                       latlong="", fromAge="", st="", jt="",  filter = "",
                       userip="1.2.3.4", version = 2,
                       userAgent="Mozilla/%2F4.0%28Firefox%29",
                       callback= "", highlight = "", chnl= ""){
  sort<-match.arg(sort)
  if(!all){
  url <- paste0("http://api.indeed.com/ads/apisearch?publisher=",publisher,
                "&q=",query,"&l=",location,"&latlong=",latlong,"&userip=",
                userip,"&useragent=",userAgent,"&format=json&start=",start,
                "&limit=",limit,"&co=",country,"&sort=",sort,"&chnl=",chnl,"&v=",version)

  as.data.frame(jsonlite::fromJSON(httr::content(httr::GET(url),
                                                 as = "text", encoding = "UTF-8")))

  }else{
    url <- paste0("http://api.indeed.com/ads/apisearch?publisher=",publisher,
                  "&q=",query,"&l=",location,"&latlong=",latlong,"&userip=",
                  userip,"&useragent=",userAgent,"&format=json&start=",0,
                  "&limit=",25,"&co=",country,"&sort=",sort,"&chnl=",chnl,"&v=",version)

    first_jobs <- jsonlite::fromJSON(httr::content(httr::GET(url),
                                     as = "text", encoding = "UTF-8"))

    jobs_lists <- lapply(seq(0,max(first_jobs$totalResults),25), function(x){
      url <- gsub("start=0",paste0("start=",x),url)
      as.data.frame(jsonlite::fromJSON(httr::content(httr::GET(url),
                                       as = "text", encoding = "UTF-8")))
    })

    jsonlite::rbind.pages(jobs_lists)
  }

}
