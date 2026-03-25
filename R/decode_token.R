#' Decode token
#'
#' Decodes the token to allow inspection of claims
#'
#' @param token a javascript web token got by running `rdbes_token()`
#'
#' @return list of claims
#'
#' @examples
#' \dontrun{
#' decode_token()
#' }
#'
#' @rdname decode_token
#'
#' @importFrom base64enc base64decode
#' @importFrom jsonlite parse_json
#'
#' @export
decode_token <- function(token = rdbes_token()) {

  json <-
    rawToChar(
      base64enc::base64decode(
        gsub(".+\\.(.+)\\..+", "\\1", token)
      )
    )

  claims <- jsonlite::parse_json(json)

  # add expiration and time to expiration
  expiration <- as.character(as.POSIXct(claims$exp, origin = "1970-01-01"))
  time_diff <- difftime(expiration, Sys.time(), units = "mins")

  c(
    claims,
    expiration = paste(expiration, "UTC"),
    time_to_expiration = paste(round(time_diff), "minutes")
  )
}
