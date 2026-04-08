#' Get the current API URL based on the environment
#'
#' This function returns the API URL based on whether the package is in development or production mode.
#'
#' @param production Logical. If TRUE, returns the production API URL. If FALSE, returns the development API URL.
#'
#' @return A character string representing the API URL.
#'
#' @export
rdbes_api <- function(production = getOption("rdbes.production")) {
  if (production) {
    getOption("rdbes.api_prod_url")
  } else {
    getOption("rdbes.api_dev_url")
  }
}
