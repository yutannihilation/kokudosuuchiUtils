skip_on_circleci <- function() {
  if (!identical(Sys.getenv("CIRCLECI"), "true")) {
    return(invisible(TRUE))
  }
  skip("On CircleCI")
}
