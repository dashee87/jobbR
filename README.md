jobbR
=====

`jobbR` is an R package that allows you to search for jobs via the Indeed API.

Getting Started
---------------

### Install

Install from GitLab

``` r
# install.packages("devtools")
devtools::install_git("https://gitlab.com/dashee87/jobbR.git")
library("jobbR")
```

You can install from GitHub (identical mirror of GitLab)

``` r
# install.packages("devtools")
devtools::install_github("dashee87/jobbR")
library("jobbR")
```

### Publisher ID

To make calls to the Indeed API, you'll need a publisher ID. It's free and can be obtained in a few minutes (just enter your name and email [here](https://secure.indeed.com/account/register)). Once you've registered, your publisher id can be found on [this page](https://ads.indeed.com/jobroll/xmlfeed).

### Tutorial

A more detailed description of the Indeed API can be found [here](https://ads.indeed.com/jobroll/xmlfeed) (accessible once you log into your publisher account).

For example, to search for data scientist jobs in London:

``` r
require(jobbR)
jobSearch(publisher="publisherID", "data+scientist", country = "uk", location = "london")
```

You can also search by jobkey

``` r
jobkeySearch(publisher="publisherID", jobkeys = c("6e9c05292f3275f5","031c1652b9692d2e"))
```

Unfortunately, the Indeed API doesn't explicity provide salary figures. To overcome this, the `getSalary` function scrapes the salary (if present) from the job description.

For more information on any function, consult the accompanying documentation:

``` r
# getSalary documentation
?getSalary
```

### Issues

Please let me know if something's not working or if you have some good wrestling puns.

[Submit issues here](https://github.com/dashee87/jobbR/issues).

Disclaimer
----------

As far as I can tell, the Indeed API is free to use and imposes no limits on calls. Nevertheless, the package is to be used at your own risk.
