#' Get a Token to Download RDBES Data
#'
#' This function authenticates with Azure using the tenant ID, client app ID, and resource specified in the package options to get an access token.
#'
#' @param invisible Logical. If TRUE (default), the token is returned invisibly
#'                           to avoid printing it in the console.
#'
#' @return Character. The access token string.
#'
#' @examples
#' \dontrun{
#'   token <- rdbes_token()
#'   # Inspect claims (out of curiosity)
#'   decode_token(token)
#' }
#'
#' @importFrom AzureAuth get_azure_token
#' @export
rdbes_token <- function(invisible = TRUE) {
  az <-
    suppressMessages(
      get_azure_token(
        resource = getOption("rdbes.resource"),
        tenant = getOption("rdbes.tenant_id"),
        app = getOption("rdbes.client_app"),
        version = 2
      )
    )

  if (invisible) {
    invisible(az$credentials$access_token)
  } else {
    az$credentials$access_token
  }
}
