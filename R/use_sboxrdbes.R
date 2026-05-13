#' Set development mode for icesRDBES
#'
#' This function allows users to switch between development and production modes for the icesRDBES
#' package. In development mode, the package will use the sboxrdbes API endpoint (sandbox environment) for testing and development purposes,
#' while in production mode, it will use the production API endpoint.
#'
#' @param flag Logical. If TRUE, sets the package to sandbox mode.
#'             If FALSE, sets it to production mode. Default is TRUE.
#'
#' @details
#' When in sandbox mode, the package will use the API endpoint specified in the `rdbes.api_sandbox_url`
#' option. When in production mode, it will use the endpoint specified in the `rdbes.api_prod_url`
#' option. This allows for easy switching between testing and live environments without needing to change code.
#'
#' @examples
#' \dontrun{
#' # Set to sandbox mode
#' use_sboxrdbes(TRUE)
#' rdbes_api() # Should return the sandbox API URL
#'
#' # Set to production mode
#' use_sboxrdbes(FALSE)
#' rdbes_api() # Should return the production API URL
#' }
#'
#' @export
use_sboxrdbes <- function(flag = TRUE) {
  options(rdbes.production = !flag)
  message("Sandbox/develpment mode is now ", ifelse(flag, "ON", "OFF"), ". RDBES API URL set to: ", rdbes_api())
}
