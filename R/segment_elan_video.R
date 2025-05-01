#' Segment a video file based on ELAN annotations
#'
#' This function inputs an ELAN file and a video and
#' outputs new videos from the ELAN annotations as segments
#'
#' @param eaf The ELAN files that supplies annotations as segments
#' @param segmentation_tier Specify tier(s) (TIER_ID) to be read
#' @param target_glosses Specify which glosses to be kept
#' @param tag Whether to use annotations as tags in filenames (default = `TRUE`)
#' @param video The filename of the video to be modified
#' @param video_format The format of the output videos (default = '.mp4')
#' @param path The path to the output videos
#' @param method Whether to use `av` (in R) or `ffmpeg` (system call) (default = "av")
#' @param preset Video quality preset (default = "medium")
#' @param crf Video processing preset (default = "12")
#' @param padding Add (+) or subtract (-) padding at start/end (default = 0 msec)
#' @return The names of the output video files
#' @export
segment_elan_video <- function(eaf,
                               segmentation_tier = NULL,
                               target_glosses = NULL,
                               tag = T,
                               video = NULL,
                               video_format = ".mp4",
                               path = NULL,
                               method = "av",
                               preset = "medium",
                               crf = "12",
                               padding = 0) {

  # Check inputs
  stopifnot("Please provide a path for the input <video>" = !is.null(video))
  stopifnot("Please provide a name for the <segmentation_tier>" = !is.null(segmentation_tier))
  stopifnot("<video> does not exist" = file.exists(video))

  # Read ELAN segmentations
  data <-
    signglossR::read_elan(eaf_file = eaf,
                          tiers = segmentation_tier,
                          target_annotations = target_glosses)

  # For storing output filenames
  outfiles <- rep(NA, nrow(data))

  # Select method (NB: ffmpeg is many times faster but requires an external call)
  if (method != "ffmpeg") {

    fps <- av::av_video_info(video)$video$framerate
    vid_imgs <- av::av_video_images(video, fps = NULL, format = "png")

  }

  # Iterate through the data frame rows to process each sign to be extracted from the video
  for (n in 1:nrow(data)) {

    # Create a tag label to add to the filename (for unique identification)
    if (tag) {

      tag_label <- paste0("_", paste0(data[n, "start"], "_", gsub("[^[:alnum:]]", "", data[n, "annotation"]), collapse = "_"))

    } else {

      tag_label <- paste0("_", paste0(data[n, "start"], collapse = "_"))

    }

    # Outfile is destination path plus infile + tags and output format
    outfile <- paste0(path, basename(gsub("\\.eaf$", "", eaf)), tag_label, video_format)

    # Stop if filename already exists (to avoid overwriting data)
    stopifnot("Error: Filename already exists! Add tags to make filenames unique." = !file.exists(outfile))

    if (method == "ffmpeg") {

      # Run ffmpeg_cut with specified parameters
      # String for ffmpeg command
      ffmpeg_cmd <-
        paste0(
          "ffmpeg -i ",
          video,
          " -ss ",
          format(as.POSIXct((data[n, ]$start-padding) / 1000, "UTC", origin = "1970-01-01"), "%H:%M:%OS3"),
          " -to ",
          format(as.POSIXct((data[n, ]$end+padding) / 1000, "UTC", origin = "1970-01-01"), "%H:%M:%OS3"),
          paste0(" -preset ", preset, " -crf ", crf, " "),
          outfile
        )

      # Run ffmpeg command
      system(ffmpeg_cmd)

    } else {

      # Define start and end times (from ELAN milliseconds) as frames (of video)
      start_frame <- round((data[n, ]$start - padding) / 1000 * fps)
      end_frame <- round((data[n, ]$end + padding) / 1000 * fps)
      segment_frames <- vid_imgs[start_frame:end_frame]

      # Output video with `av`
      av::av_encode_video(segment_frames, output = outfile, framerate = fps)

    }

    # Store output filenames
    outfiles[n] <- outfile

  }

  # Return paths to output files
  return(outfiles)

}

