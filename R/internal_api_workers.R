#' @import AzureAuth
#' @import httr
#' @import jsonlite

# 1. Internal Helper: Auth
rdbes_get_token <- function() {
  tenant_id  <- "e0b220ce-5735-4468-91df-05cae5ff1fdc"
  client_app <- "b6347a7e-5f73-463a-81b1-3781d163de19"
  resource   <- "api://18ab5ebb-1794-4e83-83f1-8fbd3dd5b152/rdbes.api.access"

  az <- AzureAuth::get_azure_token(resource = resource, tenant = tenant_id, app = client_app, version = 2)
  return(az$credentials$access_token)
}

# 2. Internal Helper: Error Handling
rdbes_handle_response <- function(res, step_name, simplify = TRUE) {
  status      <- httr::status_code(res)
  status_text <- httr::http_status(status)$reason  # Converts 400 to "Bad Request"

  if (status >= 200 && status < 300) {
    message(sprintf("[%d %s] %s", status, status_text, step_name))
    if (simplify) return(httr::content(res, "parsed")) else return(res)
  }

  err_body <- httr::content(res, "text", encoding = "UTF-8")

  # Determine category (Client Error, Server Error, etc.)
  category <- if (status >= 400 && status < 500) "CLIENT ERROR" else
    if (status >= 500) "SERVER ERROR" else "ERROR"

  # Final stop message combining Code, Text, and Category
  stop(sprintf("\n--- RDBES API ERROR ---\nStep: %s\nStatus: %d %s (%s)\nResponse: %s",
               step_name, status, status_text, category, err_body), call. = FALSE)
}


