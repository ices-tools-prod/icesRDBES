#' @docType data
#'
#' @name type_filters
#'
#' @title Type Filters for RDBES Data downloads
#'
#' @description
#' Type filters for different RDBES data types to facilitate data downloads.
#'
#' @usage
#' type_filters
#'
#' @format
#' A list containing type filters for different RDBES data types:
#' \tabular{ll}{
#'   \code{hierarchies}  \tab hierarchy\cr
#'   \code{filters}   \tab list of filters
#' }
#'
#' @details
#' Each data type (e.g., Commercial Sampling, Commercial Landing) has its own set of filters that
#' can be applied when requesting data from the RDBES API. These filters are pre-configured for the
#' year 2024 and the country code "ZW" (Zimbabwe) as an example. Users can modify these filters as
#' needed before making their API requests.
#'
#' @examples
#' type_filters[["CS"]]

NA
