% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compose_video.R
\name{compose_video}
\alias{compose_video}
\title{Compose a modified video from a video file}
\usage{
compose_video(
  video,
  filename = NULL,
  path = NULL,
  fps = 24,
  speed = 0.5,
  rep = FALSE,
  scale = 1,
  crop_region = "",
  text = NULL,
  textcolor = "white",
  boxcolor = NULL,
  font = "Helvetica",
  fontsize = "70",
  rel_fontsize = "",
  gravity = "southwest",
  location = "+20+20"
)
}
\arguments{
\item{video}{The filename to the video to be modified}

\item{filename}{The filename of the output video}

\item{path}{The path to the output video}

\item{fps}{The original framerate of the input video (default = 24; original = NULL)}

\item{speed}{Set the speed of the video to a factor (0 to 1) of the original (default is .5)}

\item{rep}{If output video is to be repeated through concatenation (default is `FALSE`)}

\item{scale}{The resizing proportion of the original video (0 to 1; default is 1 = original size)}

\item{crop_region}{The region to be cropped (e.g. '100x150+100+100', (width x height +upper_x +upper_y)).}

\item{text}{The text string to be added to the video}

\item{textcolor}{The color of the text annotation (default is "white")}

\item{boxcolor}{The color of the textbox (default is `NULL`)}

\item{font}{The font of the text annotation (default is "Helvetica")}

\item{fontsize}{The fontsize of the text annotation (default is 70)}

\item{rel_fontsize}{Whether to adjust the fontsize relative to width (x) or height (y)}

\item{gravity}{The anchor point of the added text (default is "southwest")}

\item{location}{The location of the text relative to the anchor point}
}
\value{
The name of the output video file
}
\description{
This function inputs a video and allows for repeated and/or slowmotion playback
}
