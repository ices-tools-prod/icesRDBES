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

### Core Security & Permissions

When calling the API (rdbes_download_data) for the first time
authentication is requested in the form of a pop-up login, where only
known users with permission will be given access to the
rdbes_download_data.

You can check your access by running the `decode_token` function, which
fetches a token and allows you to see what is in it, but this is just if
you are curious - it is not necessary.

``` r
library(icesRDBES)
decoded_token <- decode_token()
decoded_token[c("expiration")]
```

    ## $expiration
    ## [1] "2026-06-19 14:05:37 UTC"

``` r
# you can directly access the token with rdbes_token()
token <- rdbes_token(quiet = FALSE) # quiet=FALSE will also print the token inventory check messages
```

    ## --- Token Inventory Check ---

    ## [+]  Access Token is PRESENT

    ## [+]  Refresh Token is PRESENT

    ## [+]  ID Token is PRESENT

    ## --------------------------------

# APIs in the package icesRDBES

There are two APIs to call: - rdbes_upload_data - rdbes_download_data

The rdbes_upload_data API will screen and upload CEF data. The
rdbes_download_data API will download detailed RDBES data. Each API will
be describe in the following sections - one section for each API.

# API rdbes_upload_data

The rdbes_upload_data API can screen and upload CEF data

Calling the API The API should be called by the following call:

``` r
  rdbes_upload_data(
      file_path = ["pathAndFileNameToUpload"],
      hierarchy = ["HCL" | "HCE" | "HCS" | "HSL" | "HVD" | "HNI" | "HEN" | "HSN"])
```

The rdbes_upload_data return a message (in your R working directory -
typically the return file also opens automatically in R studio), which
can be successful for screening and uploading of data or an error report
for the failed checks. For successful screening and data upload an email
will be sent. For failure an email will not be sent, see the returned
message and potentially error file in json format.

## Examples of return messages

### Examples of a message for a successful screening and data upload

    --- Step 1: Uploading ---
    >> Upload successful.
    --- Step 2: Starting Screening ---
    --- Step 3: Monitoring Progress ---
    [14:09:45] Status: Queued
    [14:09:48] Status: Processing
    [14:09:51] Status: Processing
    [14:09:55] Status: Processing
    [14:09:58] Status: Completed
    --- Step 3.5: Downloading Reordered File ---
    >> Reordered file saved: D:/TAF/RStudio/Testttt/reordered_2026_5_11_14_9_45_155_Importtest_HNI.csv
    >> Screening Passed.
    --- Step 5: Finalizing Import ---
    >> SUCCESS: You have successfully screened your file:Importtest_HNI.csv.Your file will now be imported and you will receive an email notification upon completion of the import process.

The email is from <No-Reply-RDBES-info@ices.dk>, with subject: File
upload to the RDBES system passed screening.

### Examples of a message for a failed screening and data upload

    --- Step 1: Uploading ---
    >> Upload successful.
    --- Step 2: Starting Screening ---
    --- Step 3: Monitoring Progress ---
    [14:16:22] Status: Processing
    [14:16:25] Status: Processing
    [14:16:28] Status: Processing
    [14:16:31] Status: Failed
    --- Step 3.5: Downloading Reordered File ---
    >> Reordered file saved: D:/TAF/RStudio/Testttt/reordered_2026_5_11_14_16_22_327_SOPchecktest_noWeight_HNI.csv
    --- Step 4: Downloading Error Report ---
    !! SCREENING FAILED. Report: D:/TAF/RStudio/Testttt/Screening_Report_54f91447-285e-4fce-b3a3-7553bc95edd1.json

Browse to the Screening_Report file and open it

``` json
{
  "IsValid": false,
  "Message": " At least 1 set-based errors found. Note that a maximum of 100 errors are being reported at once.",
  "Result": [
    {
      "RecordType": "CN",
      "Errors": [
        {
          "LN": "1",
          "FieldName": "CNtotal",
          "FoundValue": "980",
          "Message": "total is > 120 % SOP or total is < 80 % SOP for 127150 (speciesCode) bll.27.3a47de (stock). Distribution Type: Age (distributionType).",
          "RuleContext": "SOP Sum: 155407.16 kg | Parent Group Total: 980 t -> 980000.00 kg | Ratio: 0.16 (15.9%)"
        }
      ]
    }
  ]
}
```

### Examples of calling the API for data upload

In the following there is given an example of a call to the RDBES API
for three RDBES CEF data type “HNI”, “HEN”, and “HSN” and one example
for the RDBES “HCS”.

National Information (NI), which consist of Catch National (CN) and
Distribution National (DN) example for upload of RDBES CEF data

``` r
library(icesRDBES)

# test file incliuded in the package
filename <- system.file("test_files/importtest_HNI.csv", package = "icesRDBES")
result <- rdbes_upload_data(filename, hierarchy = "HNI")
```

Effort National (EN) example for upload of RDBES CEF data

``` r
library(icesRDBES)

result <-
  rdbes_upload_data(
    file_path = "D:\\support\\finalcheckstestfiles\\importtest_HEN.csv",
    hierarchy = "HEN"
  )
```

Spatial National (SN) example for upload of RDBES CEF data

``` r
library(icesRDBES)

result <-
  rdbes_upload_data(
    file_path = "D:\\support\\finalcheckstestfiles\\importtest_HSN.csv",
    hierarchy = "HSN"
  )
```

Hierarchy 1 of the Commercial Sampling example for upload of RDBES data

``` r
library(icesRDBES)

result <-
  rdbes_upload_data(
    file_path = "D:\\support\\finalcheckstestfiles\\importtest_H1.csv",
    hierarchy = "H1"
  )
```

# API rdbes_download_data

The rdbes_download_data can be used to download detailed RDBES data or
CEF data from RDBES.

### Mandatory Request Object Fields

Every request must include these four core components:

`dataType`: “CS”, “CL”, “CE”, “SL”, “VD”“, or”CEF”.

`format`: “SingleCsvFile” or “CsvFilePerTable”.

`hierarchies`: “CS”, “CL”, “CE”, “SL”, “VD”, “HNI”, “HEN”, and “HSN”.

data type `filters`: The specific filter object for the data type
(e.g. csFilters).

### Download CEF data

To download all three CEF hierarchies (work will be done to update the
filter names) “HNI”, “HEN”, “HSN”, which consist of the four record
types/tables CN, DN, SN and EN in one gone please see the example below:

``` r
my_filter <- list(
  dataType = "CEF",
  format = "SingleCsvFile",
  hierarchies = list("HNI", "HEN", "HSN"),
  CEFFilters = list(
    CNVesselFlagCountry = list("ZW"),
    CNstock = list("bll.27.3a47de"),
    CNyear = list("2020","2021","2022","2023"),
    ENVesselFlagCountry = list("ZW"),
    ENyear =  list("2020","2021","2022","2023"),
    ENStockForDeterminingAreas = list("bll.27.3a47de"),
    SNVesselFlagCountry = list("ZW"),
    SNstock = list("bll.27.3a47de"),
    SNyear =  list("2020","2021","2022","2023")
  )
)
```

Files are download by calling the API like this:

``` r
zipfile <- rdbes_download_data(my_filter)
```

    ## Error:
    ## ! 
    ## --- RDBES API ERROR ---
    ## Step: Create Export Job
    ## Status: 403 Forbidden (CLIENT ERROR)
    ## Response: $message
    ## [1] "Access denied for one or more requested parameters."
    ## 
    ## $details
    ##   hierarchy allowedCountries deniedCountries message allowedRCGAreas allowedStocks  deniedStocks
    ## 1       HNI             NULL              ZW      NA            NULL          NULL bll.27.3a47de

There is not need for a filter for the Distribution National (DN)
table/record type because the DN is always downloaded in connection with
the Catch National (CN) in the National Information (NI).

The `"ENStockForDeterminingAreas"` is a filter used to determine the
effort areas that should be downloaded for the stock, (this is because,
as you know, there is not stock data in the effort table).

It is also possible to download one hierarchy: “HNI”, “HEN”, “HSN” at a
time, two tables/record types for “HNI”, and one tables/record types for
“HEN”, “HSN”, see the example below

``` r
my_filter <- list(
  dataType = "CEF",
  format = "CsvFilePerTable",
  hierarchies = list("HNI"),
  CEFFilters = list(
    CNVesselFlagCountry = list("ZW"),
    CNstock = list("bll.27.3a47de"),
    CNyear = list("2020","2021","2022","2023")
  )
)
```

Files are download by calling the API like this:

``` r
zipfile <- rdbes_download_data(my_filter)
```

    ## Error:
    ## ! 
    ## --- RDBES API ERROR ---
    ## Step: Create Export Job
    ## Status: 403 Forbidden (CLIENT ERROR)
    ## Response: $message
    ## [1] "Access denied for one or more requested parameters."
    ## 
    ## $details
    ##   hierarchy allowedCountries deniedCountries message allowedRCGAreas allowedStocks  deniedStocks
    ## 1       HNI             NULL              ZW      NA            NULL          NULL bll.27.3a47de

### Download RDBES data

To download data from RDBES, you can use the
[`rdbes_download_data`](https://ices-tools-prod.r-universe.dev/icesRDBES/doc/manual.html#rdbes_download_data)
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
zipfile <- rdbes_download_data(my_filter)
```

    ## [201 Created] Create Export Job

    ## Job ID: 2ea299e1-2f6a-49fe-9a68-404d3639f85a. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: ./export_2ea299e1-2f6a-49fe-9a68-404d3639f85a.zip

The above example dowloads a zip file to your current working directory,
the `rdbes_download_data` function returns the path to the downloaded
file as a character string, and can then be accessed using the variable
`zipfile`, for example:

``` r
# read contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HSL.csv      0 2026-06-19 15:41:00
    ## 2 Disclaimer.txt    810 2026-06-19 15:41:00

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

    ## Job ID: e70ca36e-c8f1-4dd9-b8fc-b2a167912e40. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: /tmp/Rtmp4GYCQ2/export_e70ca36e-c8f1-4dd9-b8fc-b2a167912e40.zip

``` r
# list the contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HSL.csv      0 2026-06-19 15:41:00
    ## 2 Disclaimer.txt    810 2026-06-19 15:41:00

``` r
# unzip into a folder called "rdbes" in the current working directory
unzip(zipfile, exdir = "rdbes")

# or process directly from the zip file using RDBESCore

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
could look like this, in this example we save the zip to a temporary
directory, but you can specify any directory you want:

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
      dataType = selected_type,
      format   = selected_format
    ),
    selected_filter
  )

# 3. Execute
zipfile <- rdbes_download_data(payload = my_filter, dest_dir = tempdir())
```

    ## [201 Created] Create Export Job

    ## Job ID: 06edb680-c5b2-4d05-b1b9-19145833e4c0. Polling for completion...

    ## [200 OK] Check Status

    ## Job Completed!

    ## [200 OK] Download File

    ## Process finished. File saved: /tmp/Rtmp4GYCQ2/export_06edb680-c5b2-4d05-b1b9-19145833e4c0.zip

``` r
# list the contents of the downloaded ZIP file
unzip(zipfile, list = TRUE)
```

    ##             Name Length                Date
    ## 1        HCL.csv    898 2026-06-19 15:41:00
    ## 2 Disclaimer.txt    810 2026-06-19 15:41:00

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

`CL`: clVesselFlagCountry (mandatory), clYear (optional), clArea
(optional), and clSpeciesCode (optional).

`CE`: ceVesselFlagCountry (mandatory), ceYear (optional), and ceArea
(optional).

`CS`: sdCountry (mandatory), deYear (optional), deSamplingScheme
(optional), deStratumName (optional), saSpeciesCode (optional), foArea
(optional), and leArea (optional).

`SL`: slCountry (mandatory), slYear (optional), slSpeciesListName
(optional), and slCatchFraction (optional).

`VD`: vdCountry (mandatory) and vdYear (optional).

**Country filter**

The country filter within the filter list for each data type; `CL`,
`CE`, `CS`, `SL`, and `VD` is mandatory for permission validation. The
country filters are; `clVesselFlagCountry`, `ceVesselFlagCountry`,
`sdCountry`, `slCountry`, and `vdCountry`

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
filters; `clArea`, `ceArea`, `foArea`, and `leArea` will be ignored and
the areas for the RCG will be used. \### Examples of calling the API for
data download

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
    # foArea            = list("27.2.a", "27.8.a"),       # Available Optional Filter
    # leArea            = list("27.2.a", "27.8.a")        # Available Optional Filter
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
use_sboxrdbes()
```

    ## Sandbox/develpment mode is now ON. RDBES API URL set to: https://sboxrdbes.ices.dk

and to switch back to the production database:

``` r
use_sboxrdbes(FALSE)
```

    ## Sandbox/develpment mode is now OFF. RDBES API URL set to: https://rdbes.ices.dk

icesRDBES is developed openly on
[GitHub](https://github.com/ices-tools-prod/icesRDBES).

Feel free to open an
[issue](https://github.com/ices-tools-prod/icesRDBES/issues) there if
you encounter problems or have suggestions for future versions.

The current development version can be installed using:

``` r
library(remotes)
install_github("ices-tools-prod/icesRDBES@development")
```
