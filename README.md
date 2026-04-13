<!--
[![CRAN Status](https://r-pkg.org/badges/version/icesRDBES)](https://cran.r-project.org/package=icesRDBES)
[![CRAN Monthly](https://cranlogs.r-pkg.org/badges/icesRDBES)](https://cran.r-project.org/package=icesRDBES)
[![CRAN Total](https://cranlogs.r-pkg.org/badges/grand-total/icesRDBES)](https://cran.r-project.org/package=icesRDBES)
-->

[<img align="right" alt="ICES Logo" height="40" src="https://www.ices.dk/_layouts/15/1033/images/icesimg/iceslogo.png">](https://www.ices.dk)

# icesRDBES

Tools to support the ICES Regional DataBase and Estimation System
([RDBES](https://sboxrdbesapi.ices.dk/rdbescatalogue/)) to access,
analyse, and process fisheries data collected under the EU Data
Collection Framework.

icesRDBES is implemented as an [R](https://www.r-project.org) package
and available on
[ices-tools-prod.r-universe](https://ices-tools-prod.r-universe.dev/icesRDBES).

The RDBES API uses a single “Request Object” contract to handle multiple
data types. This document explains how to configure the payload for each
specific data type.

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

## API Endpoints

The API endpoint “api_url” for the RDBES is:

RDBES: <https://rdbesapi.ices.dk/api/v1/export-jobs>

For RDBES Test system called SboxRDBES the API endpoint is:

Test system for RDBES: <https://sboxrdbesapi.ices.dk/api/v1/export-jobs>

### Core Security & Permissions

When calling the API (rdbes_download_data) for the first time
authentication is requested in the form of a pop-up login, where only
known users with permission will be given access to the
rdbes_download_data.

You can check your access by running the `decode_token` function, which
fetches a token and allows you to see what is in it:

``` r
library(icesRDBES)
decoded_token <- decode_token()
decoded_token[c("unique_name", "expiration")]
```

    ## $unique_name
    ## [1] "colin.millar@ices.dk"
    ## 
    ## $expiration
    ## [1] "2026-04-13 15:25:30 UTC"

### Mandatory Request Object Fields

Every request must include these five core components:

`dataType`: “CS”, “CL”, “CE”, “SL”, or “VD”.

`format`: “SingleCsvFile” or “CsvFilePerTable”.

`hierarchies`: The specific hierarchy list for the data type.

data type `filters`: The specific filter object for the data type
(e.g. csFilters).

### Calling the API

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

    ## Job ID: 5370a912-c44b-4232-a75e-5bd1e8f57421. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: ./export_5370a912-c44b-4232-a75e-5bd1e8f57421.zip

    ## [1] "./export_5370a912-c44b-4232-a75e-5bd1e8f57421.zip"

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
    slYear = list("2024")
  )
)

# Download the data using the defined filter and save it to the specified directory
zipfile <- rdbes_download_data(my_filter, dest_dir = tempdir())
```

    ## [201 Created] Create Export Job

    ## Job ID: b26cfa6c-63f8-4df2-a4a9-138cc9d38b80. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: /tmp/RtmpBQcqTJ/export_b26cfa6c-63f8-4df2-a4a9-138cc9d38b80.zip

``` r
# list the contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HSL.csv      0 2026-04-13 16:35:00
    ## 2 Disclaimer.txt    810 2026-04-13 16:35:00

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
      format            = selected_format
    ),
    selected_filter
  )

# 3. Execute
zipfile <- rdbes_download_data(payload = my_filter, dest_dir = tempdir())
```

    ## [201 Created] Create Export Job

    ## Job ID: 49d23ca8-1aec-4818-8bc1-8d00c3f7580e. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: /tmp/RtmpBQcqTJ/export_49d23ca8-1aec-4818-8bc1-8d00c3f7580e.zip

``` r
# list the contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HCL.csv    898 2026-04-13 16:36:00
    ## 2 Disclaimer.txt    810 2026-04-13 16:36:00

``` r
# list the contents of the downloaded ZIP file to local directory
unzip(zipfile, exdir = "rdbes")
hcl <- read.csv("rdbes/HCL.csv", header = FALSE)
```

### Quick Tips for Users

- Multiple Values: You can filter for multiple values like this:
  list(“2023”, “2024”).
- Activating Optional Filters: Remove the \# from a line in the examples
  to use that specific filter.
- Permission Errors: Check that your account has the right access.

## Details

The payload is a list of parameters with the following structure:

``` r
list(
  dataType          = string,
  format            = string,
  hierarchies       = list(list of hierarchies),
  [datatype]Filters         = list([list of filters depending on the dataType])
)
```

The following are the filters for each data type:

CL: clVesselFlagCountry (mandatory), clYear (optional), clArea
(optional), and clSpeciesCode (optional).

CE: ceVesselFlagCountry (mandatory), ceYear (optional), and ceArea
(optional).

CS: sdCountry (mandatory), deYear (optional), deSamplingScheme
(optional), deStratumName (optional), saSpeciesCode (optional), foArea
(optional), and leArea (optional).

SL: slCountry (mandatory), slYear (optional), slSpeciesListName
(optional), and slCatchFraction (optional).

VD: vdCountry (mandatory) and vdYear (optional).

**Country filter**

The country filter within the filter list for each data type; CL, CE,
CS, SL, and VD is mandatory for permission validation. The country
filters are; clVesselFlagCountry, ceVesselFlagCountry, sdCountry,
slCountry, and vdCountry

For data submitters and national estimators a specific county filter
must be provided e.g., “ES” or “FR” (for test data “ZW”)

For RCG chairs the country filter “All” should be used to request all
countries within the Regional Coordination Group (RCG) that your account
is authorized to download. Multiple countries can like in the RDBES web
interface not be specified. If only one country is provided, it is
expected that it is for the persons own country.

**Area filter**

For Commercial Landings (CL) the area filter is “clArea”, and for
Commercial Effort (CE) the area filter is “ceArea”. For Commercial
Sample (CS) there are two area filters “foArea” and “leArea” depending
on the hierarchy (the area is an optional filter). That means if CS data
are requested for one or more of the hierarchies; H1, H2, H3, H6, H10,
and H13, please fill-in/use foArea in the CS filters. If CS data area
requested for one or more of the hierarchies; H4, H5, H7, H8, H9, H11,
and H12, please fill-in/use leArea in the CS filters.

When RCG chairs use the country filter “All” for Commercial Landings
(CL), Commercial Effort (CE) or Commercial Sampling (CS) the area
filters; clArea, ceArea, foArea, and leArea will be ignored and the
areas for the RCG will be used.

### Examples of calling the API for data download

In the following there is given an example of a call to the RDBES API
for each data type “CS”, “CL”, “CE”, “SL”, and “VD”.

*Commercial Sampling (CS) example for download of RDBES data*

``` r
library(icesRDBES)

my_payload <- list(
  dataType          = "CS",
  format            = " CsvFilePerTable ",
  hierarchies       = list("H1", "H5", "H6", "H13"),
  csFilters         = list(
    sdCountry         = list("All"),  # Mandatory for Permissions
    deYear            = list("2024") # Available Optional Filter
    # deSamplingScheme  = list(),       # Available Optional Filter
    # deStratumName     = list(),     # Available Optional Filter
    # saSpeciesCode     = list(),       # Available Optional Filter
    # foArea            = list(“27.2.a”, “27.8.a”),       # Available Optional Filter
    # leArea            = list(“27.2.a”, “27.8.a”)        # Available Optional Filter
  )
)

rdbes_download_data(payload = my_payload)
```

*Commercial Landings (CL) example for download of RDBES data*

``` r
library(icesRDBES)

my_payload <- list(
  dataType          = "CL",
  format            = "SingleCsvFile",
  hierarchies       = list("HCL"),
  clFilters         = list(
    clVesselFlagCountry = list("All"), # Mandatory for Permissions
    clYear              = list("2024")  # Available Optional Filter
    # clArea              = list(),      # Available Optional Filter
    # clSpeciesCode       = list()       # Available Optional Filter
  )
)

rdbes_download_data(payload = my_payload)
```

*Commercial Effort (CE) example for download of RDBES data*

``` r
library(icesRDBES)

my_payload <- list(
  dataType          = "CE",
  format            = "SingleCsvFile",
  hierarchies       = list("HCE"),
  ceFilters         = list(
    ceVesselFlagCountry = list("All"), # Mandatory for Permissions
    ceYear              = list("2024")  # Available Optional Filter
    # ceArea              = list()       # Available Optional Filter
  )
)

rdbes_download_data(payload = my_payload)
```

*Species List (SL) example for download of RDBES data*

``` r
library(icesRDBES)

my_payload <- list(
  dataType          = "SL",
  format            = "SingleCsvFile",
  hierarchies       = list("HSL"),
  slFilters         = list(
    slCountry         = list("All"),  # Mandatory for Permissions
    slYear            = list("2024")  # Available Optional Filter
    # slSpeciesListName = list(""),     # Available Optional Filter
    # slCatchFraction   = list()        # Available Optional Filter
  )
)

rdbes_download_data(payload = my_payload)
```

*Vessel Details (VD) example for download of RDBES data*

``` r
library(icesRDBES)

my_payload <- list(
  dataType          = "VD",
  format            = "SingleCsvFile",
  hierarchies       = list("HVD"),
  vdFilters         = list(
    vdCountry = list("All"),           # Mandatory for Permissions
    vdYear    = list("2024")           # Available Optional Filter
  )
)

rdbes_download_data(payload = my_payload)
```

## Development

To use the development database you need to run the following code
before you download data:

``` r
use_rdbes_development(TRUE)
```

    ## Development mode is now ON. RDBES API URL set to: https://sboxrdbesapi.ices.dk/api/v1/export-jobs

and to switch back to the production database:

``` r
use_rdbes_development(FALSE)
```

    ## Development mode is now OFF. RDBES API URL set to: https://rdbesapi.ices.dk/api/v1/export-jobs

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
