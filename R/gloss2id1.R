#' Find ID number from ID gloss
#'
#' This function inputs an ID gloss and outputs an
#' ID number linked to the same sign (its dictionary entry).
#'
#' @param gloss ID gloss for the sign
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The unique ID gloss linked to the sign used as its label in Signbank
#' @export
gloss2id1 <- function(gloss, acronym="sts") {
  acronym <- tolower(acronym)
  if (acronym == "asl") {
    gloss <- signglossR::gloss2id_asl(gloss)
  }
  if (acronym %in% c("sts", "ssl")) {
    gloss <- signglossR::gloss2id_sts(gloss)
  }
  return(gloss)
}
