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


#' Download RDBES Data
#'
#' This function authenticates with Azure, creates an export job, polls for completion,
#' and downloads the resulting ZIP file to the current working directory.
#'
#' @param url Character. The RDBES API export URL (e.g., "https://rdbesapi.ices.dk/api/v1/export-jobs").
#' @param payload List. The filter configuration including hierarchies, format, and filters.
#'
#' @details
#' The payload should be a nested list. Example:
#' \code{list(hierarchies = list("H1"), format = "SingleCsvFile", csFilters = list(...))}
#'
#' @return Character. The path to the downloaded ZIP file.
#' @export
#' @examples
#' \dontrun{
#'   my_payload <- list(hierarchies = list("H1"), format = "SingleCsvFile")
#'   rdbes_download_data("https://api-url-here", my_payload)
#' }
#'
rdbes_download_data <- function(url, payload) {
  # Get Token automatically
  access_token <- rdbes_get_token()

  # Step 1: Create Job
  res <- httr::POST(
    url = url,
    httr::add_headers(Authorization = paste("Bearer", access_token)),
    body = jsonlite::toJSON(payload, auto_unbox = TRUE, null = "null"),
    httr::content_type_json()
  )
  job_data <- rdbes_handle_response(res, "Create Export Job")
  job_id   <- job_data$id

  # Step 2: Wait
  status_url <- paste0(url, "/", job_id)
  message("Job ID: ", job_id, ". Polling for completion...")
  repeat {
    Sys.sleep(5)
    res_status <- httr::GET(status_url, httr::add_headers(Authorization = paste("Bearer", access_token)))
    job_info <- rdbes_handle_response(res_status, "Check Status")

    if (job_info$status == "Completed") {
      message("Job Completed!")
      break
    } else if (job_info$status == "Failed") {
      stop(sprintf("Job %s failed on server: %s", job_id, job_info$errorMessage))
    }
    message("Current status: ", job_info$status)
  }

  # Step 3: Download
  dest_file <- paste0("export_", job_id, ".zip")
  res_dl <- httr::GET(
    url = paste0(url, "/", job_id, "/file"),
    httr::add_headers(Authorization = paste("Bearer", access_token)),
    httr::write_disk(dest_file, overwrite = TRUE)
  )
  rdbes_handle_response(res_dl, "Download File", simplify = FALSE)

  message("Process finished. File saved: ", dest_file)
  return(dest_file)
}
