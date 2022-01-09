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
  datalist = list()
  n <- 1
  for (f in filenames){
    f_index <- 1
    eaf <- xml2::read_xml(paste0(path, f))
    vids <- xml2::xml_attr(xml2::xml_find_all(eaf, ".//MEDIA_DESCRIPTOR"), "RELATIVE_MEDIA_URL")
    vid <- vids[1]
    fps <- 25
    if (video != "" & file.exists(video)) {
      vid <- video
    }
    if (file.exists(vid)) {
      fps <- av::av_video_info(vid)$video$framerate
    }
    ts <- xml2::xml_find_all(eaf, ".//TIME_SLOT")
    times <- hash::hash()
    times[xml2::xml_attr(ts, "TIME_SLOT_ID")] <- xml2::xml_attr(ts, "TIME_VALUE")
    all_tiers <- xml2::xml_find_all(eaf, ".//TIER")
    all_tiers <- all_tiers[xml2::xml_attr(all_tiers, "TIER_ID") %in% tiers]
    start <- hash::hash()
    end <- hash::hash()
    start[xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "ANNOTATION_ID")] <- hash::values(times[xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "TIME_SLOT_REF1")])
    end[xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "ANNOTATION_ID")] <- hash::values(times[xml2::xml_attr(xml2::xml_children(xml2::xml_children(all_tiers)), "TIME_SLOT_REF2")])
    annotation_tiers <- xml2::xml_attr(all_tiers, "TIER_ID")
    annotation_tier_types <- xml2::xml_attr(all_tiers, "LINGUISTIC_TYPE_REF")
    annotation_participant <- xml2::xml_attr(all_tiers, "PARTICIPANT")
    t_num <- 1
    tier_data <- list()
    for (t in all_tiers) {
      tier_id <- xml2::xml_attr(t, "TIER_ID")
      tier_cat <- ""
      if (tier_id %in% segmentation_tiers) {
        tier_cat <- "segmentation"
      }
      if (tier_id %in% gloss_tiers) {
        tier_cat <- "gloss"
      }
      tier_type <- xml2::xml_attr(t, "LINGUISTIC_TYPE_REF")
      tier_participant <- xml2::xml_attr(t, "PARTICIPANT")
      for (annotation in xml2::xml_children(xml2::xml_children(t))) {
        annotation_label <- xml2::xml_attr(annotation, "ANNOTATION_ID")
        annotation_start <- xml2::xml_attr(annotation, "TIME_SLOT_REF1")
        annotation_end <- xml2::xml_attr(annotation, "TIME_SLOT_REF2")
        annotation_text <- xml2::xml_text(xml2::xml_child(annotation))
        annotation_data <- data.frame(f_index)
        annotation_data <- data.frame(annotation_data,
                                      filename=f,
                                      videopath=vid,
                                      tier_type,
                                      tier_cat,
                                      tier_id,
                                      tier_participant,
                                      annotation_label,
                                      annotation_text,
                                      start_time=as.numeric(as.character(hash::values(times[annotation_start]))),
                                      end_time=as.numeric(as.character(hash::values(times[annotation_end]))),
                                      duration=as.numeric(as.character(hash::values(times[annotation_end])))-as.numeric(as.character(hash::values(times[annotation_start]))),
                                      start_frame=round(fps*(as.numeric(as.character(hash::values(times[annotation_start])))/1000)),
                                      end_frame=round(fps*(as.numeric(as.character(hash::values(times[annotation_end])))/1000)))
        rownames(annotation_data) <- NULL
        tier_data[[t_num]] <- annotation_data
        t_num <- t_num + 1
        f_index <- f_index + 1
      }
    }
    file_data <- data.table::rbindlist(tier_data)
    datalist[[n]] <- file_data
    n <- n+1
  }
  elan_data <- data.table::rbindlist(datalist)
  return(elan_data)
}
