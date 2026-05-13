
#' @importFrom httr status_code http_status content
#' @importFrom jsonlite fromJSON toJSON

# used in rdbes_donload_data
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


# used in rdbes_upload_data
rdbes_handle_status <- function(res) {
  code <- httr::status_code(res)
  content_raw <- httr::content(res, as = "text", encoding = "UTF-8")
  content <- if (content_raw != "") jsonlite::fromJSON(content_raw) else list()

  if (code >= 200 && code < 300) {
    return(content)
  } else {
    err_msg <- "An unknown error occurred."
    if (is.list(content)) {
      err_msg <- if(!is.null(content$Message)) content$Message
      else if(!is.null(content$message)) content$message
      else if(!is.null(content$error)) content$error
      else "Unknown API Error"
    }
    stop(paste0("[Error ", code, "]: ", err_msg))
  }
}
