#' @details The function will first try to use the provided \code{blank}. If the
#'   blank is ommitted, the function will then try to extract the blank from the
#'   \code{eemlist} object. This is done by looking for sample names containing
#'   one of these complete or partial strings (ignoring case):
#'
#'   \enumerate{ \item nano \item miliq \item milliq \item mq \item blank }
#'
#'   Note that if \code{blank} is omitted, the function will group the
#'   \code{eemlist} based on file location and will assumes that there is a
#'   blank sample in each folder. In that context, the blank will be used on
#'   each sample in the same folder. If more than one blank is found they will
#'   be averaged (a message will be printed if this appends).
#'
#'   Consider the following example where there are two folders that could
#'   represent scans performed on two different days `scans_day_1` and
#'   `scans_day_2`.
#'
#'   \tabular{ll}{ scans_day_1\tab\cr \tab nano.csv\cr \tab sample1.csv\cr \tab
#'   sample2.csv\cr \tab sample3.csv\cr scans_day_2 \tab\cr \tab blank.csv\cr
#'   \tab s1.csv\cr \tab s2.csv\cr \tab s3.csv\cr }
#'
#'   In each folder there are three samples and one blank files. In that
#'   context, `eem_remove_blank()` will use the blank `nano.csv` from
#'   `sample1.csv`, `sample2.csv` and `sample3.csv`. The same strategy will be
#'   used for files in folder `scans_day_2` but with blank named `blank.csv`.
#'
#'   Note that the blanks eem are not returned by the function.
