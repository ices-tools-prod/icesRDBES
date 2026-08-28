
#' @importFrom httr status_code http_status content
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom utils capture.output

# used in rdbes_donload_data
rdbes_handle_response <- function(res, step_name = "", simplify = TRUE) {
  status <- status_code(res)
  status_text <- http_status(status)$reason  # Converts 400 to "Bad Request"

  if (status >= 200 && status < 300) {
    message(sprintf("[%d %s] %s", status, status_text, step_name))
    if (simplify) {
      return(content(res))
    } else {
      return(res)
    }
  }

  content <- content(res, simplifyVector = TRUE)
  err_body <- paste(capture.output(content), collapse = "\n")

  category <-
    if (status >= 400 && status < 500) {
      "CLIENT ERROR"
    } else if (status >= 500) {
      "SERVER ERROR"
    } else {
      "ERROR"
    }

  # stop with detailed message
  msg <-
    sprintf(
      "\n--- RDBES API ERROR ---\nStep: %s\nStatus: %d %s (%s)\nResponse: \n%s",
      step_name, status, status_text, category, err_body
    )
  stop(msg, call. = FALSE)
}
