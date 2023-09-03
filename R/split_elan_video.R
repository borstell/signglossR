#' Split ELAN video
#'
#' This function reads ELAN annotation file (.eaf) in a directory and outputs a video
#' for each annotation cell as the segmentation and can label the output file with the annotation text
#'
#' @param elan_path The path to a single ELAN .eaf file or a directory with .eaf files
#' @param segmentation_tier List of specific tiers with segmentation annotations to be included
#' @param video_path Specify a video path to be used (if none, uses the ELAN path and filename)
#' @param annotation_tag If TRUE, uses the annotation text of the cell as the filename
#' @param padding Adds (or subtracts if negative) frames (in milliseconds) before+after segment duration
#' @param video_input_format Specify input video format in directory (default is .mp4)
#' @param video_output_format Specify output video format in directory (default is .mp4)
#' @return Video files based on ELAN segmentations
#' @export
split_elan_video <- function(elan_path="", segmentation_tier="", video_path="", annotation_tag=F, padding=0, video_input_format=".mp4", video_output_format=".mp4"){

  original_video_path <- video_path

  annotations <- signglossR::read_elan(path = elan_path)
  annotations <- dplyr::mutate(annotations,
                               start_time = format(as.POSIXct((start-padding) / 1000, "UTC", origin = "1970-01-01"), "%H:%M:%OS3"),
                               end_time = format(as.POSIXct((end+padding) / 1000, "UTC", origin = "1970-01-01"), "%H:%M:%OS3"))
  annotations <- dplyr::filter(annotations, tier == segmentation_tier)

  for (filename in unique(annotations$file)) {
    current_annotations <- dplyr::filter(annotations, file==filename)

    for (i in 1:nrow(current_annotations)) {

      current_filename <- current_annotations[i,]$file

      if (tools::file_ext(original_video_path) != ""){
        bare_video_path <- stringr::str_sub(original_video_path, 1, -5)
        video_input_format <- paste0(".", tools::file_ext(original_video_path))
      } else {
        bare_video_path <- paste0(original_video_path, gsub(".eaf", "", current_filename))
        video_path <- paste0(bare_video_path, video_input_format)
      }

      tag <- ""
      if(annotation_tag){
        tag <- paste0("_", stringr::str_replace_all(current_annotations[i,]$annotation, "[^[:alnum:]]", "-"))
      }

      segment_path <- paste0(bare_video_path, "_", stringr::str_pad(i, width=3, pad="0"), tag)

      ffmpeg_cmd <- paste0("ffmpeg -i ",
                           video_path,
                           " -ss ",
                           current_annotations[i,]$start_time,
                           " -to ",
                           current_annotations[i,]$end_time,
                           " ",
                           segment_path,
                           video_output_format)
      system(ffmpeg_cmd)
    }
  }
}
