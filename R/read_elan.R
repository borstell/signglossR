#' Read ELAN data (.eaf)
#'
#' This function reads ELAN annotation files (.eaf) in a directory,
#' or a single ELAN file, and outputs a data frame
#'
#' @param path The path to a single ELAN .eaf file or a directory with .eaf files
#' @return A data frame containing the ELAN data
#' @export
read_elan <- function(path){
  if (tools::file_ext(path) == "eaf") {
    filenames <- c(gsub(".*/","",path))
    path <- stringr::str_replace(path, gsub(".*/","",path), "")
  }
  else {
    filenames = list.files(path = path, pattern="*.eaf$")
  }

  all_annotations <- dplyr::tibble()
  for (f in filenames){
    message(paste0("Reading file: ",f))
    eaf <- xml2::read_xml(paste0(path, f))
    ts <- xml2::xml_find_all(eaf, ".//TIME_SLOT")
    times <- dplyr::tibble(t=xml2::xml_attr(ts, "TIME_SLOT_ID"),
                           time=xml2::xml_attr(ts, "TIME_VALUE"))
    all_tiers <- xml2::xml_find_all(eaf, ".//TIER")

    annotations <- dplyr::tibble(file=f,
                                 a=xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "ANNOTATION_ID"),
                                 t1=xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "TIME_SLOT_REF1"),
                                 t2=xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "TIME_SLOT_REF2"),
                                 annotation=xml2::xml_text(xml2::xml_children(xml2::xml_children(all_tiers))),
                                 ref=xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "ANNOTATION_REF"))

    a <- c()
    t1 <- c()
    t2 <- c()
    ref <- c()
    annotation <- c()
    tier <- c()
    lingtype <- c()
    participant <- c()
    annotator <- c()
    for (n in xml2::xml_children(xml2::xml_children(all_tiers))){
      a <- c(a, xml2::xml_attr(n, "ANNOTATION_ID"))
      t1 <- c(t1, xml2::xml_attr(n, "TIME_SLOT_REF1"))
      t2 <- c(t2, xml2::xml_attr(n, "TIME_SLOT_REF2"))
      ref <- c(ref, xml2::xml_attr(n, "ANNOTATION_REF"))
      annotation <- c(annotation, xml2::xml_text(n))
      tier <- c(tier, xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(n)),"TIER_ID"))
      lingtype <- c(lingtype, xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(n)),"LINGUISTIC_TYPE_REF"))
      participant <- c(participant, xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(n)),"PARTICIPANT"))
      annotator <- c(annotator, xml2::xml_attr(xml2::xml_parent(xml2::xml_parent(n)),"ANNOTATOR"))
    }

    annotations <- dplyr::tibble(
      file=f,
      a,
      t1,
      t2,
      ref,
      annotation,
      tier,
      tier_type=lingtype,
      participant,
      annotator
    )

    parent_annotations <- dplyr::select(dplyr::filter(annotations, is.na(ref)),-ref)

    child_annotations <- dplyr::select(dplyr::filter(annotations,!is.na(ref)),-c(t1,t2))
    child_annotations <- dplyr::left_join(child_annotations, dplyr::select(parent_annotations,a,tier), by=c("ref"="a"))
    child_annotations <- dplyr::rename(child_annotations,
                                       tier = tier.x,
                                       parent_tier = tier.y)

    file_annotations <- dplyr::bind_rows(parent_annotations,child_annotations)
    file_annotations <- dplyr::left_join(file_annotations, times, by=c("t1"="t"))
    file_annotations <- dplyr::rename(file_annotations, start = time)
    file_annotations <- dplyr::left_join(file_annotations, times, by=c("t2"="t"))
    file_annotations <- dplyr::rename(file_annotations, end = time)
    file_annotations <- dplyr::mutate(file_annotations,
                                      end = as.numeric(end),
                                      start = as.numeric(start),
                                      duration = end-start)

    all_annotations <- dplyr::bind_rows(all_annotations, file_annotations)
  }

  return(all_annotations)
}
