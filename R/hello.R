#' Hello World
#'
#' Print a hello world message.
#'
#' @param name a character string giving a name to greet.
#'
#' @return
#' Invisibly returns a character string with the greeting message.
#'
#' @examples
#' hello()
#' hello("RDBES")
#'
#' @export
hello <- function(name = "world") {
  msg <- paste0("Hello, ", name, "!")
  message(msg)
  invisible(msg)
}
