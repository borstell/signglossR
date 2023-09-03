#' Segment ELAN data (.eaf)
#'
#' This function reads ELAN annotation file (.eaf) in a directory and outputs a data frame
#' for segmentation purposes (images and videos)
#'
#' @param path The path to a single ELAN .eaf file or a directory with .eaf files
#' @param segmentation_tier List of specific tiers with segmentation annotations to be included
#' @param gloss_tier List of specific tiers with gloss annotations to be included
#' @param video Specify a video path to be used (if not, first linked video per eaf is used)
#' @return A data frame containing the ELAN data
#' @export
segment_elan <- function(path, segmentation_tier="", gloss_tier="", video="") {
  if (assertthat::is.string(segmentation_tier)) {
    segmentation_tiers <- c()
    for (s_tier in stringr::str_split(segmentation_tier, ",")) {
      segmentation_tiers <- c(segmentation_tiers, s_tier)
    }
  }
  else {
    segmentation_tiers <- segmentation_tier
  }
  if (assertthat::is.string(gloss_tier)) {
    gloss_tiers <- c()
    for (g_tier in stringr::str_split(gloss_tier, ",")) {
      gloss_tiers <- c(gloss_tiers, g_tier)
    }
  }
  else {
    gloss_tiers <- gloss_tier
  }
  tiers <- c(segmentation_tiers, gloss_tiers)
  if (tools::file_ext(path) == "eaf") {
    filenames <- c(gsub(".*/","",path))
    path <- stringr::str_replace(path, gsub(".*/","",path), "")
  }
  else {
    filenames = list.files(path = path, pattern="*.eaf$")
  }
  all_annotations <- dplyr::tibble()
  for (f in filenames){
    message(paste0("Reading file: ", f))
    eaf <- xml2::read_xml(paste0(path, f))
    ts <- xml2::xml_find_all(eaf, ".//TIME_SLOT")
    times <- dplyr::tibble(t=xml2::xml_attr(ts, "TIME_SLOT_ID"),
                           time=xml2::xml_attr(ts, "TIME_VALUE"))
    all_tiers <- xml2::xml_find_all(eaf, ".//TIER")
    vids <- xml2::xml_attr(xml2::xml_find_all(eaf, ".//MEDIA_DESCRIPTOR"), "RELATIVE_MEDIA_URL")
    vid <- vids[1]
    fps <- 25
    if (video != "" & file.exists(video)) {
      vid <- video
    }
    if (file.exists(vid)) {
      fps <- av::av_video_info(vid)$video$framerate
    }
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
                                      end_time = as.numeric(end),
                                      start_time = as.numeric(start),
                                      duration = end_time-start_time)
    file_annotations <- dplyr::rename(file_annotations, annotation_text = annotation)
    file_annotations <- dplyr::mutate(file_annotations, tier_cat = dplyr::case_when(tier %in% segmentation_tiers ~ "segmentation",
                                                                                    tier %in% gloss_tiers ~ "gloss",
                                                                                    .default = ""))
    file_annotations <- dplyr::mutate(file_annotations,
                                      start_frame = round(start_time/1000*fps),
                                      end_frame = round(end_time/1000*fps),
                                      videopath = vid,
                                      f_index = dplyr::row_number())

    all_annotations <- dplyr::bind_rows(all_annotations, file_annotations)
  }

  return(all_annotations)
}
