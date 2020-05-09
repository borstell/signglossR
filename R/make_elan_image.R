#' Make ELAN image
#'
#' This function creates image files (with or without text) from an ELAN annotation file
#'
#' @param path The path to a single ELAN .eaf file or a directory with .eaf files
#' @param destination The path/filename of the output image
#' @param segmentation_tier List of specific tiers with segmentation annotations to be included
#' @param gloss_tier List of specific tiers with gloss annotations to be included
#' @param video Specify a video path to be used (if not, first linked video per eaf is used)
#' @param combine Represent each sign by an overlay of the first and last frame of the sign (default=TRUE)
#' @param scale The resizing proportion of the original image (0 to 1; default is 1 = original size)
#' @param crop Whether to crop image to region (`crop=FALSE` is default)
#' @param region The region to be cropped (defaults to '100x150+100+100', (width x height +upper_x +upper_y)). Only for `crop=TRUE`
#' @param text The text string to be added to the image
#' @param textcolor The color of the text annotation (default is "white")
#' @param font The font of the text annotation (default is "Helvetica")
#' @param fontsize The fontsize of the text annotation (default is 70)
#' @param gravity The anchor point of the added text (default is "southwest")
#' @param location The location of the text relative to the anchor point
#' @param border Set to `TRUE` if you want a black border frame for the output image
#' @return The name of the image file(s) created
#' @export
make_elan_image <- function(path, destination="./", segmentation_tier="", gloss_tier="", video="", combine=TRUE, scale=1, crop=FALSE, region='100x150+100+100', text="", textcolor="white", font="Helvetica", fontsize="40", gravity="southwest", location="+20+20", border=FALSE) {
  d <- signglossR::read_elan(path, segmentation_tier, gloss_tier, video)

  segs <- dplyr::filter(d, d$tier_cat == "segmentation")
  segs[order(segs$start_time),]

  glosses <- dplyr::filter(d, d$tier_cat == "gloss")
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
  if (fontsize == "1") {
    fontsize <- 0.1*v_h
  }
  v <- magick::image_read_video(vid, fps=fps)
  for (n in 1:max(unique(glosses$seg))) {
    signs <- c()
    for (m in 1:nrow(dplyr::filter(glosses, glosses$seg==n))) {
      fname <- paste0(tempdir(),"/","seq_",m,".png")
      fname <- gsub("//", "/", fname)
      if (combine) {
        sign1 <- v[dplyr::filter(glosses, glosses$seg==n)[m,]$start_frame]
        sign2 <- v[dplyr::filter(glosses, glosses$seg==n)[m,]$end_frame]
        aname <- paste0(tempdir(),"/", "A.png")
        aname <- gsub("//", "/", aname)
        bname <- paste0(tempdir(),"/", "B.png")
        bname <- gsub("//", "/", bname)
        magick::image_write(sign1, aname)
        magick::image_write(sign2, bname)
        signglossR::combine_images(c(aname, bname), fname, overlay=T)
        signglossR::make_image_ex(fname, fname, crop = crop, scale = scale, region = region, text = dplyr::filter(glosses, glosses$seg==n)[m,]$annotation_text, textcolor = textcolor, font = font, fontsize = fontsize, gravity = gravity, location = location, border = border)
        signs <- c(signs, fname)
      }
      else {
        sign <- v[dplyr::filter(glosses, glosses$seg==n)[m,]$start_frame]
        magick::image_write(sign, fname)
        signglossR::make_image_ex(fname, fname, crop = crop, scale = scale, region = region, text = dplyr::filter(glosses, glosses$seg==n)[m,]$annotation_text, textcolor = textcolor, font = font, fontsize = fontsize, gravity = gravity, location = location, border = border)
        signs <- c(signs, fname)
      }
    }
    if (destination == "./" | max(unique(glosses$seg))>1) {
      outfile <- paste0(gsub(".eaf", "", gsub(".*/", "", dplyr::filter(glosses, glosses$seg==n)[1,]$file)), "_", n, ".png")
      outfile <- paste0(getwd(), "/", outfile)
    }
    else {
      outfile <- destination
    }
    signglossR::combine_images(signs, outfile)
  }
  return(outfile)
}
