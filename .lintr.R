linters <- lintr::all_linters(
  packages = "lintr",
  line_length_linter(80L),
  object_length_linter = NULL,
  object_name_linter = NULL,
  object_usage_linter = NULL,
  unused_import_linter = NULL,
  one_call_pipe_linter = NULL,
  consecutive_mutate_linter = NULL,
  unnecessary_nesting_linter = NULL,
  undesirable_function_linter = undesirable_function_linter(
    fun = modify_defaults(
      defaults = default_undesirable_functions,
      abort = "use cli::cli_abort()",
      basename = "use path_file()",
      cli_alert_danger = "use cli::cli_inform()",
      cli_alert_info = "use cli::cli_inform()",
      cli_alert_success = "use cli::cli_inform()",
      cli_alert_warning = "use cli::cli_inform()",
      dir = "use dir_ls()",
      dir.create = "use dir_create()",
      dirname = "use path_dir()",
      file.copy = "use file_copy()",
      file.create = "use file_create()",
      file.exists = "use file_exists()",
      file.info = "use file_info()",
      file.path = "use path()",
      inform = "use cli::cli_inform()",
      library = NULL,
      message = "use cli::cli_inform()",
      normalizePath = "use path_real()",
      readLines = "use read_lines()",
      stop = "use cli::cli_abort()",
      unlink = "use file_delete()",
      warn = "use cli::cli_warn()",
      warning = "use cli::cli_warn()",
      writeLines = "use write_lines()"
    ),
    symbol_is_undesirable = FALSE
  ),
  undesirable_operator_linter(
    op = all_undesirable_operators
  )
)

