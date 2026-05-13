token_inventory_check <- function(az) {
  # Fetching list of credential keys safely
  cred_names <- names(az$credentials)

  message("--- Token Inventory Check ---")

  # 1. Check for Access Token
  if ("access_token" %in% cred_names) {
    message("[+]  Access Token is PRESENT")
  } else {
    message("[X] Access Token is MISSING")
  }

  # 2. Check for Refresh Token
  if ("refresh_token" %in% cred_names) {
    message("[+]  Refresh Token is PRESENT")
  } else {
    message("[X] Refresh Token is MISSING")
  }

  # 3. Check for ID Token
  if ("id_token" %in% cred_names) {
    message("[+]  ID Token is PRESENT")
  } else {
    message("[X] ID Token is MISSING")
  }

  message("--------------------------------")
}
