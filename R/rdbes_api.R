#' Get the current API URL based on the environment
#'
#' This function returns the API URL based on whether the package is in development or production mode.
#'
#' @return A character string representing the API URL.
#'
#' @export
rdbes_api <- function() {
  if (getOption("rdbes.production")) {
    getOption("rdbes.api_prod_url")
  } else {
    getOption("rdbes.api_dev_url")
  }
}
