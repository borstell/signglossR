#' Animate OpenPose signer
#'
#' This function inputs a data frame from `read_openpose(wide=TRUE)` (.eaf) and outputs an animated .gif of an avatar signing
#'
#' @param data The data frame with OpenPose data in wide format
#' @param destination The path/filename of the output .gif
#' @param skin_col Skin color of the avatar
#' @param clothes_col Color of the avatar's clothes
#' @param turtleneck Whether the avatar should wear a turtleneck sweater (default=FALSE)
#' @param fancy Whether the avatar should be dressed in a tuxedo, top hat, and monocle (default=FALSE)
#' @return A .gif file with an animated avatar
#' @export
make_avatar <- function(data, destination="./signglossR_avatar.gif", skin_col="lightgrey", clothes_col="lightgrey", turtleneck=FALSE, fancy=FALSE) {
  coord_dist <- function(x1,y1, x2, y2) {
    return(sqrt((x1-x2)^2+(y1-y2)^2))
  }
  frames <- nrow(data)
  skin <- skin_col
  clothes <- clothes_col
  hat <- "black"
  rh <- skin
  lh <- skin
  clothes_alpha <- .95
  hat_alpha <- 0
  turtle_alpha <- 0
  monocle_alpha <- 0
  if (turtleneck) {
    turtle_alpha=clothes_alpha
  }
  if (fancy){
    clothes = "black"
    hat_alpha = 1
    monocle_alpha = 1
  }
  avatar <- ggplot2::ggplot(data) +
    # Head
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_0, y0 = data$y_0, a = coord_dist(mean(data$x_0), mean(data$y_0), mean(data$x_18), mean(data$y_18))*1.1, b = coord_dist(mean(data$x_0), mean(data$y_0), mean(data$x_18), mean(data$y_18))*1.6, angle=0), fill = skin, alpha=1, linetype=0) +
    # Monocle
    ggplot2::geom_point(ggplot2::aes(x=data$x_0-0.025, y=data$y_0), color="black", shape=21, size=6, alpha=monocle_alpha) +
    # Tophat
    ggplot2::geom_rect(ggplot2::aes(xmin = data$x_0-0.1, ymin = data$y_0/1.4, xmax = data$x_0+0.1, ymax = data$y_0/1.4+0.05), fill = hat, alpha=hat_alpha, size=13, linejoin = "round") +
    ggplot2::geom_rect(ggplot2::aes(xmin = data$x_0-0.07, ymin = data$y_0/1.4, xmax = data$x_0+0.07, ymax = data$y_0/1.4-0.15), fill = hat, alpha=hat_alpha, size=13, linejoin = "round") +
    # Turtleneck
    ggplot2::geom_rect(ggplot2::aes(xmin = data$x_0-0.05, ymin = data$y_1/1.1, xmax = data$x_0+0.05, ymax = data$y_1/1.1-0.08), fill = clothes, alpha=turtle_alpha, size=13, linejoin = "round") +
    # Chest
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_0, y0 = data$y_1, a = coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_1), mean(data$y_1)), b =  coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_1), mean(data$y_1))*.7, angle=0), fill = clothes, alpha=clothes_alpha, linetype=0) +
    # Torso
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_0, y0 = data$y_1+abs(mean(data$y_0)-mean(data$y_8))*.3, a = coord_dist(mean(data$x_2), mean(data$y_2), mean(data$x_1), mean(data$y_1)), b =  coord_dist(mean(data$x_1), mean(data$y_1), mean(data$x_8), mean(data$y_8))*.45, angle=0), fill = clothes, alpha=clothes_alpha, linetype=0) +
    # Left + Right shoulder
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_2, y0 = data$y_2, a = .08, b =  .08, angle=0), fill = clothes, alpha=clothes_alpha, linetype=0) +
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_5, y0 = data$y_5, a = .08, b =  .08, angle=0), fill = clothes, alpha=clothes_alpha, linetype=0) +
    # Right arm (upper, lower, hand)
    ggplot2::geom_segment(ggplot2::aes(x = data$x_2, y = data$y_2, xend = data$x_3, yend = data$y_3), color = clothes, alpha=clothes_alpha, size=15, linejoin = "round") +
    ggplot2::geom_segment(ggplot2::aes(x = data$x_3, y = data$y_3, xend = data$x_4, yend = data$y_4), color = clothes, alpha=clothes_alpha, size=13, linejoin = "round") +
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_4, y0 = data$y_4, a = .05, b =  .05, angle=0), fill = rh, alpha=1, linetype=0) +
    # Left arm (upper, lower, hand)
    ggplot2::geom_segment(ggplot2::aes(x = data$x_5, y = data$y_5, xend = data$x_6, yend = data$y_6), color = clothes, alpha=clothes_alpha, size=15, linejoin = "round") +
    ggplot2::geom_segment(ggplot2::aes(x = data$x_6, y = data$y_6, xend = data$x_7, yend = data$y_7), color = clothes, alpha=clothes_alpha, size=13, linejoin = "round") +
    ggforce::geom_ellipse(ggplot2::aes(x0 = data$x_7, y0 = data$y_7, a = .05, b =  .05, angle=0), fill = lh, alpha=1, linetype=0) +
    ggplot2::xlim(0,1) + ggplot2::ylim(0,1) +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_fixed() +
    ggplot2::theme_void() +
    gganimate::transition_states(
      data$frame,
      transition_length = 0,
      state_length = 1) +
    gganimate::enter_fade() +
    gganimate::exit_shrink() +
    gganimate::ease_aes('sine-in-out')
  return(gganimate::animate(avatar, nframes = frames, fps = 25, renderer = gganimate::gifski_renderer(destination), end_pause = 1, rewind = FALSE))
}
