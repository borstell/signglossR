#' Make ELAN video
#'
#' This function creates video file clips (with or without text) from an ELAN annotation file
#'
#' @param path The path to a single ELAN .eaf
#' @param destination The path/file of the output video
#' @param segmentation_tier List of specific tiers with segmentation annotations to be included
#' @param gloss_tier1 Name of gloss tier with gloss annotations to be included
#' @param gloss_tier2 Name of second gloss tier with gloss annotations to be included
#' @param gloss_gravity The gravity (=anchor point) of the text of the gloss text
#' @param video Specify a video path to be used (if not, first linked video is used)
#' @param segment Whether to cut each segmentation into a separate video (default=FALSE)
#' @param gloss_size Fontsize of gloss text in video (default=1; 0 results in no glosses)
#' @param subtitle_size Fontsize of subtitle text based on segmentation tier cell text in video (default=1; 0 results in no subtitles)
#' @param padding Whether to add n frames before and after the start/end to segment (default=0)
#' @return A video file based on ELAN annotations
#' @export
make_elan_video <- function(path, destination="./", segmentation_tier="", gloss_tier1="", gloss_tier2="", gloss_gravity="northwest", video="", segment=TRUE, gloss_size=1, subtitle_size=1, padding=0) {
  d <- signglossR::segment_elan(path, segmentation_tier, gloss_tier=paste(gloss_tier1, gloss_tier2, sep=","), video)
  segs <- dplyr::filter(d, d$tier_cat == "segmentation")
  segs[order(segs$start_time),]

  tier_cat_gloss <- "gloss"
  if (gloss_tier1 == "" & gloss_tier2 == "") {
    tier_cat_gloss <- "segmentation"
  }
  glosses <- dplyr::filter(d, d$tier_cat == tier_cat_gloss)
  glosses <- glosses[order(glosses$start_time),]
  glosses$seg <- ""
  for (n in 1:nrow(segs)) {
    glosses$seg <- ifelse(sapply(glosses$start_time, function(s)
      any(segs[n,]$start_time <= s & segs[n,]$end_time >= s)),segs[n,]$f_index, glosses$seg)
  }

  if (video == "" & file.exists(paste0(getwd(), "/", gsub(".*/", "", as.character(d[1,]$videopath))))) {
    vid <- paste0(getwd(), "/", gsub(".*/", "", as.character(d[1,]$videopath)))
  }
  else {
    vid <- video
  }
  vid_info <- av::av_video_info(vid)
  fps <- vid_info$video$framerate
  v_h <- vid_info$video$height
  if (subtitle_size == 1) {
    subtitle_size <- 0.06*v_h
  }
  if (gloss_size == 1) {
    gloss_size <- 0.1*v_h
  }
  v <- magick::image_read_video(vid, fps=fps)

  all_framelist <- list()
  all_framelist[[1]] <- data.frame(frame=1:length(v))
  framelist <- list()
  for (n in 1:nrow(segs)){
    r <- data.frame(segment=n, file=segs[n,]$file, video=segs[n,]$video, subtitle=segs[n,]$annotation_text, frame=segs[n,]$start_frame:segs[n,]$end_frame)
    framelist[[n]] <- r
  }
  frame_data <- data.table::rbindlist(framelist)
  frame_data <- dplyr::left_join(all_framelist[[1]], frame_data)

  if (gloss_tier1 != "") {
    framelist_g1 <- list()
    g1 <- glosses[glosses$tier_id==gloss_tier1,]
    for (n in 1:nrow(g1)){
      r <- data.frame(file=g1[n,]$file, right_gloss=g1[n,]$annotation_text, frame=g1[n,]$start_frame:g1[n,]$end_frame)
      framelist_g1[[n]] <- r
    }
    frame_data_g1 <- data.table::rbindlist(framelist_g1)

    frame_data <- dplyr::left_join(frame_data, frame_data_g1, by=c("frame", "file"))
  }
  if (gloss_tier2 != "") {
    framelist_g2 <- list()
    g2 <- glosses[glosses$tier_id==gloss_tier2,]
    for (n in 1:nrow(g2)){
      r <- data.frame(file=g2[n,]$file, left_gloss=g2[n,]$annotation_text, frame=g2[n,]$start_frame:g2[n,]$end_frame)
      framelist_g2[[n]] <- r
    }
    frame_data_g2 <- data.table::rbindlist(framelist_g2)

    frame_data <- dplyr::left_join(frame_data, frame_data_g2, by=c("frame", "file"))
  }
  frame_data <- sapply(frame_data, as.character)
  frame_data[is.na(frame_data)] <- ""
  frame_data <- data.frame(frame_data)

  frame_data <- frame_data %>%
    dplyr::mutate(sub = as.character(frame_data$subtitle)) %>%
    dplyr::mutate(sub = ifelse(nchar(sub)>30, paste0(substring(sub, 1, round(nchar(sub)/2)), sub(" ", "\n", substring(sub, round(nchar(sub)/2+1), nchar(sub)))), sub))
  frame_data <- frame_data %>%
    dplyr::mutate(frame = as.numeric(as.character(frame_data$frame)))

  clips <- list()
  if (segment == FALSE) {
    start <- min(segs$start_frame)-padding
    end <- max(segs$end_frame)+padding
    clips[[1]] <- c(start, end)
  }
  else {
    for (n in 1:nrow(segs)) {
      start <- segs[n,]$start_frame-padding
      end <- segs[n,]$end_frame+padding
      clips[[n]] <- c(start, end)
    }
  }
  outfiles <- c()
  for (n in 1:length(clips)){
    start <- clips[[n]][1]
    end <- clips[[n]][2]
    clip_frames <- v[start:end]
    if (gloss_tier2 != "") {
      gloss_gravity <-  "northwest"
      clip_frames <- magick::image_annotate(clip_frames, text = frame_data[start:end,]$left_gloss, size = gloss_size, color = "white", boxcolor = "black", gravity = "northeast")
    }
    if (gloss_tier1 != "") {
      clip_frames <- magick::image_annotate(clip_frames, text = frame_data[start:end,]$right_gloss, size = gloss_size, color = "white", boxcolor = "black", gravity = gloss_gravity)
    }
    if (subtitle_size > 0 & segmentation_tier != "") {
      clip_frames <- magick::image_annotate(clip_frames, text = frame_data[start:end,]$sub, size = subtitle_size, color = "white", boxcolor = "black", gravity = "south")
    }
    if (destination == "./" | length(clips)>1) {
      outfile <- paste0(destination, gsub(".eaf", "", gsub(".*/", "", path)), "_", n, ".mp4")
    }
    else {
      outfile <- destination
    }
    magick::image_write_video(clip_frames, path=outfile, framerate=fps)
    outfiles <- c(outfiles, outfile)
  }
  clip_frames <- NULL
  v <- NULL
  return(outfiles)
}
