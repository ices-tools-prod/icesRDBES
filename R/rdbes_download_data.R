#' Download RDBES Data
#'
#' This function authenticates with Azure, creates an export job, polls for completion,
#' and downloads the resulting ZIP file to the current working directory.
#'
#' @param payload List. The filter configuration including hierarchies, format, and filters.
#'
#' @details
#' The payload should be a nested list. Example:
#' \code{list(hierarchies = list("H1"), format = "SingleCsvFile", csFilters = list(...))}
#'
#' @return Character. The path to the downloaded ZIP file.
#'
#' @examples
#' \dontrun{
#'   my_payload <- list(hierarchies = list("H1"), format = "SingleCsvFile")
#'   rdbes_download_data(my_payload)
#' }
#'
#' @importFrom httr POST GET add_headers content write_disk content_type_json
#' @importFrom jsonlite toJSON
#' @export
rdbes_download_data <- function(payload) {
  # Get Token automatically
  access_token <- rdbes_token()

  # load API URL from options
  url <- getOption("rdbes.api_url")

  # Step 1: Create Job
  res <- POST(
    url = url,
    add_headers(Authorization = paste("Bearer", access_token)),
    body = toJSON(payload, auto_unbox = TRUE, null = "null"),
    content_type_json()
  )
  job_data <- rdbes_handle_response(res, "Create Export Job")
  job_id   <- job_data$id

  # Step 2: Wait
  status_url <- paste0(url, "/", job_id)
  message("Job ID: ", job_id, ". Polling for completion...")
  repeat {
    Sys.sleep(5)
    res_status <- GET(status_url, add_headers(Authorization = paste("Bearer", access_token)))
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
  res_dl <- GET(
    url = paste0(url, "/", job_id, "/file"),
    add_headers(Authorization = paste("Bearer", access_token)),
    write_disk(dest_file, overwrite = TRUE)
  )
  rdbes_handle_response(res_dl, "Download File", simplify = FALSE)

  message("Process finished. File saved: ", dest_file)
  return(dest_file)
}
