##' Perform job search by job key
##'
##' Performs a job search by sending job keys to the Indeed API. The output
##' fields are identical to \code{jobSearch}, except that the response does not
##' include the various search parameters, such as query or radius.
##'
##' @param publisher (string) Publisher ID (e.g. "901314124155123"), which is
##'   assigned when you register as a publisher. No default. (required)
##' @param jobkeys (sting <vector>). Job keys. Vector of job keys specifying the
##'   jobs to look up. This parameter is required. No default.
##' @param version (integer). Specifies the version of the API you wish to use.
##'   All publishers should be using version 2. Currently available versions are
##'   1 and 2. Default is 2.
##'
##' @return The output is converted from its JSON format to a data frame.
##'
##' @examples
##' \dontrun{
##' # returns information for the two provided jobkeys
##' jobkeySearch(publisher="123456789", c("6e9c05292f3275f5","031c1652b9692d2e"))
##' }
##'

jobkeySearch <- function(publisher, jobkeys, version = 2){

  url <- paste0("http://api.indeed.com/ads/apigetjobs?publisher=",publisher,
                "&jobkeys=",paste(jobkeys,collapse = ","),"&format=json&v=",version)

  as.data.frame(jsonlite::fromJSON(httr::content(httr::GET(url),
                                                 as = "text", encoding = "UTF-8")))
}
