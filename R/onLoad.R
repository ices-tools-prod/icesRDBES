
.onLoad <- function(libname, pkgname) {

  # set some default options
  opts <-
    c(
      rdbes.tenant_id  = "'e0b220ce-5735-4468-91df-05cae5ff1fdc'",
      rdbes.client_app = "'b6347a7e-5f73-463a-81b1-3781d163de19'",
      rdbes.resource   = "'api://18ab5ebb-1794-4e83-83f1-8fbd3dd5b152/rdbes.api.access'",
      rdbes.api_url    = "'https://rdbesapi.ices.dk/api/v1/export-jobs'"
    )

  for (i in setdiff(names(opts), names(options()))) {
        eval(parse(text = paste0("options(", i, "=", opts[i], ")")))
  }

  invisible()
}
