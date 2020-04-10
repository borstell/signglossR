#' Search corpus
#'
#' This function inputs search string and searches it in an online corpus
#'
#' @param gloss ID number for the sign
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The url of the linked corpus search
#' @export
search_corpus <- function(gloss="*", acronym="sts") {
  acronym <- tolower(acronym)
  if (acronym %in% c("sts", "ssl")) {
    url <- paste0("https://teckensprakskorpus.su.se/#/?q=", gloss)
  }
  else {
    message(paste0("Language <", acronym, "> not available."))
    stop()
  }
  utils::browseURL(url=url)
  return(url)
}
