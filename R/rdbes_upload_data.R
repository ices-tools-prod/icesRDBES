#' Upload RDBES Data
#'
#' This function authenticates with Azure, uploads a file, starts a screening job, polls for completion,
#' and downloads the resulting reordered file if available.
#'
#' @param file_path Character. The path to the file to upload.
#' @param hierarchy Character. The hierarchy type for the upload.
#' @param production Logical. Optional. Whether to use the production API endpoint. Defaults to getOption("rdbes.production").
#' @param verbose Logical. Optional. Whether to print verbose HTTP request/response details. Defaults to FALSE.
#'
#' @return Character. The path to the downloaded ZIP file.
#'
#' @examples
#' \dontrun{
#' filename <- system.file("test_files/importtest_HNI.csv", package = "icesRDBES")
#'
#' result <- rdbes_upload_data(file_path = filename, hierarchy = "HNI")
#' }
#'
#' @importFrom utils URLencode browseURL packageVersion
#' @importFrom httr timeout add_headers POST GET write_disk upload_file verbose
#' @export
rdbes_upload_data <- function(file_path, hierarchy, production = getOption("rdbes.production"), verbose = FALSE) {
  if (!file.exists(file_path)) stop(paste("File not found:", file_path))

  # Get Token automatically
  access_token <- rdbes_token()

  # load API URL from options
  api_root_url <- rdbes_api(production = production, type = "upload")

  # useful request components
  headers <-
    add_headers(
      Authorization = paste("Bearer", access_token),
      "X-RDBES-Package-Version" = as.character(packageVersion("icesRDBES"))
    )
  long_timeout <- timeout(600)

  # 1. Upload
  message("\n--- Step 1: Uploading ---")

  res_up <- POST(
    url = paste0(api_root_url, "/api/Upload/UploadFile"),
    headers, long_timeout,
    body = list(File = upload_file(file_path), isSLTobeConverted = "false"),
    encode = "multipart",
    if (verbose) verbose() else NULL
  )

  up_data <- rdbes_handle_status(res_up)
  message(">> Upload successful.")

  # 2. Start Screening
  message("\n--- Step 2: Starting Screening ---")
  res_start <- POST(
    url = paste0(api_root_url, "/api/Screening/start"),
    headers,
    body = list(
      RealFileName = basename(file_path),
      ModifiedFileNameOnServer = up_data$modifiedFileNameOnServer,
      Hierarchy = hierarchy
    ),
    encode = "json",
    if (verbose) verbose() else NULL
  )
  start_data <- rdbes_handle_status(res_start)
  job_id <- start_data$jobId %||% start_data$JobId
  if (is.null(job_id)) stop("No JobId returned from API, contact rdbes@ices.dk.")

  # 3. Polling
  message("\n--- Step 3: Monitoring Progress ---")
  repeat {
    res_status <-
      GET(
        url = paste0(api_root_url, "/api/Screening/Status/", job_id),
        headers,
        if (verbose) verbose() else NULL
      )

    status_data <- rdbes_handle_status(res_status)

    is_ready <- status_data$IsReady %||% status_data$isReady
    raw_status <- status_data$Status %||% status_data$status

    req_confirm <- status_data$RequiresConfirmation %||% FALSE
    serial_num <- status_data$FailedCheckSerialNumber
    srv_message <- status_data$Message %||% "Action confirmation required."

    message(
      paste0("[", format(Sys.time(), "%H:%M:%S"), "] Status: ", raw_status %||% "Processing")
    )

    # Automatically download and open report during a confirmation pause
    if (isTRUE(req_confirm)) {
      message("\n--- Downloading Action Confirmation Report ---")
      confirm_filename <- paste0("Screening_Confirmation_Report_", job_id, ".json")
      confirm_path <- file.path(getwd(), confirm_filename)

      # Request the checkpoint payload directly from your existing download API endpoint
      res_dl_confirm <-
        GET(
          url = paste0(api_root_url, "/api/Screening/DownloadReport/", job_id),
          headers,
          write_disk(confirm_path, overwrite = TRUE)
        )

      if (status_code(res_dl_confirm) == 200) {
        message(">> Confirmation report saved: ", confirm_path)

        # Open it in the editor or browser window immediately so the user can look at it
        if (has_rstudio()) {
          rstudioapi::navigateToFile(confirm_path)
        } else {
          browseURL(confirm_path)
        }
      }

      message("\n!! INTERACTIVE CHECKPOINT [Step ", serial_num, "]: ", srv_message)
      user_choice <- readline("Confirm  data deletion and resume validation checks? (Y/N): ")

      if (tolower(user_choice) == "y") {
        message(">> Resuming backend check engine...")
        res_resume <-
          POST(
            url = paste0(api_root_url, "/api/Screening/ConfirmAction/", job_id),
            headers,
            body = list(SerialNumber = serial_num),
            encode = "json"
          )
        rdbes_handle_status(res_resume)
        Sys.sleep(3)
        next
      } else {
        stop("Pipeline aborted by user at confirmation checkpoint.")
      }
    }

    if (isTRUE(is_ready)) break
    Sys.sleep(3)
  }

  # 4. Handle Results
  has_errors <- status_data$HasErrors %||% status_data$hasErrors
  reordered_name <- status_data$ReorderedFileName %||%   status_data$reorderedFileName

  # --- Step 3.5: Download Reordered CSV ---
  if (!is.null(reordered_name)) {
    message("\n--- Step 3.5: Downloading Reordered File ---")
    reordered_path <- file.path(getwd(), reordered_name)

    res_reordered <-
      GET(
        url =  paste0(api_root_url, "/api/Screening/DownloadReordered/", URLencode(reordered_name)),
        headers,
        long_timeout,
        write_disk(reordered_path, overwrite = TRUE),
        if (verbose) verbose() else NULL
      )

    if (status_code(res_reordered) == 200) {
      message(">> Reordered file saved: ", reordered_path)
      if (has_rstudio()) {
        rstudioapi::navigateToFile(reordered_path)
      } else {
        browseURL(reordered_path)
      }
    } else {
      message(">> [HTTP ", status_code(res_reordered), "] Reordered file not available.")
    }
  }

  # --- Step 4.0: Download Error Report ---
  if (isTRUE(has_errors)) {
    message("\n--- Step 4: Downloading Error Report ---")
    report_filename <- paste0("Screening_Report_", job_id, ".json")
    report_path <- file.path(getwd(), report_filename)

    res_dl <- GET(
      url = paste0(api_root_url, "/api/Screening/DownloadReport/", job_id),
      headers, write_disk(report_path, overwrite = TRUE)
    )

    if (status_code(res_dl) != 200) stop("Failed to download error report.")

    report <- fromJSON(report_path)
    message("!! SCREENING FAILED. Report: ", report_path)

    if (has_rstudio()) {
      rstudioapi::navigateToFile(report_path)
    } else {
      browseURL(report_path)
    }

    # Duplicate check logic
    is_duplicate <- grepl("duplicate", tolower(report$Message)) || !is.null(report$TotalErrorsFound)
    should_call_enqueue <- FALSE
    if (is_duplicate) {
      if (tolower(readline("Overwrite and import? (Y/N): ")) == "y") {
        should_call_enqueue <- TRUE
      } else {
        return(report)
      }
    } else {
      return(report)
    }
  } else {
    message("\n>> Screening Passed.")
    should_call_enqueue <- TRUE
  }

  # 5. Final Step: Enqueue
  if (should_call_enqueue) {
    message("\n--- Step 5: Finalizing Import ---")
    res_import <-
      GET(
        url = paste0(api_root_url, "/api/ImportQueue/Enqueue"),
        headers,
        query =
        list(
          modifiedFileNameOnServer = up_data$modifiedFileNameOnServer,
          uploadedFileName = basename(file_path),
          hierarcyType = hierarchy,
          overWrite = "true"
        ),
        if (verbose) verbose() else NULL
      )
    import_data <- rdbes_handle_status(res_import)
    message(">> SUCCESS: ", import_data$Message)
    return(invisible(import_data))
  }
}
