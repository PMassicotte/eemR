eem_import_function_factory <- function(import_function) {
  if (is.function(import_function)) {
    return(import_function)
  }

  switch(
    import_function,
    "cary" = eem_read_cary,
    "aqualog" = eem_read_aqualog,
    "shimadzu" = eem_read_shimadzu,
    "fluoromax4" = eem_read_fluoromax4,
    # is.function = return(import_function),
    stop(
      "I do not know how to read a file from ",
      import_function,
      ". You may want to create your own import function. See vignette browseVignettes('eemR')"
    )
  )
}

eem_check_import_function <- function(f) {
  arguments <- formals(f)

  if (!all(names(arguments) %in% c("file", "data"))) {
    stop("Your custom function use only two arguments: file, data")
  }

  grepl("eem\\(.*\\)", body(f))
}
