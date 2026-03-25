
#' @importFrom httr status_code http_status content
#' @importFrom jsonlite fromJSON toJSON

# 2. Internal Helper: Error Handling
rdbes_handle_response <- function(res, step_name, simplify = TRUE) {
  status      <- status_code(res)
  status_text <- http_status(status)$reason  # Converts 400 to "Bad Request"

  if (status >= 200 && status < 300) {
    message(sprintf("[%d %s] %s", status, status_text, step_name))
    if (simplify) return(content(res, "parsed")) else return(res)
  }

  err_body <- content(res, "text", encoding = "UTF-8")

  # Determine category (Client Error, Server Error, etc.)
  category <- if (status >= 400 && status < 500) "CLIENT ERROR" else
    if (status >= 500) "SERVER ERROR" else "ERROR"

  # Final stop message combining Code, Text, and Category
  stop(sprintf("\n--- RDBES API ERROR ---\nStep: %s\nStatus: %d %s (%s)\nResponse: %s", step_name, status, status_text, category, err_body), call. = FALSE)
}
