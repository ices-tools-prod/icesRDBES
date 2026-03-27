#' Set development mode for icesRDBES
#'
#' This function allows users to switch between development and production modes for the icesRDBES
#' package. In development mode, the package will use the development API endpoint, while in
#' production mode, it will use the production API endpoint.
#'
#' @param flag Logical. If TRUE, sets the package to development mode.
#'             If FALSE, sets it to production mode. Default is TRUE.
#'
#' @details
#' When in development mode, the package will use the API endpoint specified in the `rdbes.api_dev_url`
#' option. When in production mode, it will use the endpoint specified in the `rdbes.api_prod_url`
#' option. This allows for easy switching between testing and live environments without needing to change code.
#'
#' @examples
#' \dontrun{
#' # Set to development mode
#' use_rdbes_development(TRUE)
#' rdbes_api() # Should return the development API URL
#'
#' # Set to production mode
#' use_rdbes_development(FALSE)
#' rdbes_api() # Should return the production API URL
#' }
#'
#' @export
use_rdbes_development <- function(flag = TRUE) {
  options(rdbes.production = !flag)
  message("Development mode is now ", ifelse(flag, "ON", "OFF"), ". RDBES API URL set to: ", rdbes_api())
}
