#' Get the current API URL based on the environment
#'
#' This function returns the API URL based on whether the package is in development or production mode.
#'
#' @param production Logical. If TRUE, returns the production API URL. If FALSE, returns the development API URL.
#' @param type Character. The type of API URL to return, either "upload" or "download". Defaults to "upload".
#'
#' @return A character string representing the API URL.
#'
#' @export
rdbes_api <- function(production = getOption("rdbes.production"), type = c("upload", "download")) {
  type <- match.arg(type)
  if (production) {
    if (type == "upload") {
      getOption("rdbes.api_prod_upload_url")
    } else {
      getOption("rdbes.api_prod_download_url")
    }
  } else {
    if (type == "upload") {
      getOption("rdbes.api_sbox_upload_url")
    } else {
      getOption("rdbes.api_sbox_download_url")
    }
  }
}
