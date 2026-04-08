[![CRAN
Status](https://r-pkg.org/badges/version/icesRDBES)](https://cran.r-project.org/package=icesRDBES)
[![CRAN
Monthly](https://cranlogs.r-pkg.org/badges/icesRDBES)](https://cran.r-project.org/package=icesRDBES)
[![CRAN
Total](https://cranlogs.r-pkg.org/badges/grand-total/icesRDBES)](https://cran.r-project.org/package=icesRDBES)

[<img align="right" alt="ICES Logo" height="40" src="https://www.ices.dk/_layouts/15/1033/images/icesimg/iceslogo.png">](https://www.ices.dk)

# icesRDBES

Tools to support the ICES Regional DataBase and Estimation System
([RDBES](https://sboxrdbesapi.ices.dk/rdbescatalogue/)) to access,
analyse, and process fisheries data collected under the EU Data
Collection Framework.

icesRDBES is implemented as an [R](https://www.r-project.org) package
and available on
[ices-tools-prod.r-universe](https://ices-tools-prod.r-universe.dev/icesRDBES).

## Installation

icesRDBES can be installed from CRAN using the `install.packages`
command:

``` r
install.packages('icesRDBES', repos = c('https://ices-tools-prod.r-universe.dev', 'https://cloud.r-project.org'))
```

## Usage

For a summary of the package:

``` r
library(icesRDBES)
?icesRDBES
```

### Tokens

You can only access RDBES data if you have an account and the necessary
permissions. You can check your access by running the `decode_token`
function, which fetches a token and allows you to see what is in it:

``` r
library(icesRDBES)
decoded_token <- decode_token()
decoded_token[c("unique_name", "expiration")]
```

    ## $unique_name
    ## [1] "colin.millar@ices.dk"
    ## 
    ## $expiration
    ## [1] "2026-04-08 15:47:46 UTC"

### Downloading data

To download data from RDBES, you can use the `rdbes_download_data`
function. For example:

``` r
library(icesRDBES)
my_filter <- list(
  dataType = "SL",
  format = "SingleCsvFile",
  hierarchies = list("HSL"),
  slFilters = list(
    slCountry = list("ZW"),
    slYear = list("2024")
  )
)
rdbes_download_data(my_filter)
```

    ## [201 Created] Create Export Job

    ## Job ID: 04cab180-a728-438f-aae8-f925c763d05e. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: ./export_04cab180-a728-438f-aae8-f925c763d05e.zip

    ## [1] "./export_04cab180-a728-438f-aae8-f925c763d05e.zip"

The above example dowloads a zip file to your current working directory,
the `rdbes_download_data` function returns the path to the downloaded
file as a character string.

## Simple workflow examples

A simple workflow could look like this:

``` r
library(icesRDBES)
# Define the filter for the data you want to download
my_filter <- list(
  dataType = "SL",
  format = "SingleCsvFile",
  hierarchies = list("HSL"),
  slFilters = list(
    slCountry = list("ZW"),
    slYear = list("2024"),
    includeDisclaimer = FALSE
  )
)

# Download the data using the defined filter and save it to the specified directory
zipfile <- rdbes_download_data(my_filter, dest_dir = tempdir())
```

    ## [201 Created] Create Export Job

    ## Job ID: b98767c2-91be-40f8-9745-1f210678f08c. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: /tmp/RtmpAfaNsW/export_b98767c2-91be-40f8-9745-1f210678f08c.zip

``` r
# list the contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HSL.csv      0 2026-04-08 17:12:00
    ## 2 Disclaimer.txt    810 2026-04-08 17:12:00

``` r
# unzip into a folder called "rdbes" in the current working directory
unzip(zipfile, exdir = "rdbes")

# read in csv file
# ...
```

### Using predefined filters

the icesRDBES package also provides predefined filters for each data
type, which can be used to simplify the process of creating the filter
list.

``` r
library(icesRDBES)
# see ?type_filters
names(type_filters)
```

    ## [1] "CS" "CL" "CE" "SL" "VD"

``` r
type_filters[["CE"]]
```

    ## $hierarchies
    ## $hierarchies[[1]]
    ## [1] "HCE"
    ## 
    ## 
    ## $ceFilters
    ## $ceFilters$ceYear
    ## $ceFilters$ceYear[[1]]
    ## [1] "2024"
    ## 
    ## 
    ## $ceFilters$ceVesselFlagCountry
    ## $ceFilters$ceVesselFlagCountry[[1]]
    ## [1] "ZW"
    ## 
    ## 
    ## $ceFilters$ceArea
    ## list()

A more complex example using the predefined filters for each data type
could look like this:

``` r
library(icesRDBES)

selected_type   <- "CL"              # Options: "CS", "CL", "CE", "SL", "VD"
selected_format <- "SingleCsvFile"   # Options: "SingleCsvFile", "CsvFilePerTable"
selected_filter <- type_filters[[selected_type]]

# modify the filter here if needed, e.g. to add a species code filter
selected_filter
```

    ## $hierarchies
    ## $hierarchies[[1]]
    ## [1] "HCL"
    ## 
    ## 
    ## $clFilters
    ## $clFilters$clYear
    ## $clFilters$clYear[[1]]
    ## [1] "2024"
    ## 
    ## 
    ## $clFilters$clVesselFlagCountry
    ## $clFilters$clVesselFlagCountry[[1]]
    ## [1] "ZW"
    ## 
    ## 
    ## $clFilters$clArea
    ## list()
    ## 
    ## $clFilters$clSpeciesCode
    ## list()

``` r
# 1. Initialize filter with constant parameters
my_filter <-
  c(
    list(
      dataType          = selected_type,
      format            = selected_format,
      includeDisclaimer = TRUE
    ),
    selected_filter
  )

# 3. Execute
zipfile <- rdbes_download_data(payload = my_filter, dest_dir = tempdir())
```

    ## [201 Created] Create Export Job

    ## Job ID: 23de2ccc-39fd-4b31-886e-14c6b4bcb09a. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: /tmp/RtmpAfaNsW/export_23de2ccc-39fd-4b31-886e-14c6b4bcb09a.zip

``` r
# list the contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HCL.csv    898 2026-04-08 17:12:00
    ## 2 Disclaimer.txt    810 2026-04-08 17:12:00

``` r
# list the contents of the downloaded ZIP file to local directory
unzip(zipfile, exdir = "rdbes")
hcl <- read.csv("rdbes/HCL.csv", header = FALSE)
```

## Development

icesRDBES is developed openly on
[GitHub](https://github.com/ices-tools-prod/icesRDBES).

Feel free to open an
[issue](https://github.com/ices-tools-prod/icesRDBES/issues) there if
you encounter problems or have suggestions for future versions.

The current development version can be installed using:

``` r
library(remotes)
install_github("ices-tools-prod/icesRDBES")
```
