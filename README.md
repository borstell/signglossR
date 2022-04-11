<img src="https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/sticker_signglossR.png" width="600">

# signglossR
**v2.2.2**
[![R build status](https://github.com/borstell/signglossR/workflows/R-CMD-check/badge.svg)](https://github.com/borstell/signglossR/actions)

An R package that facilitates *visual* representation of sign language data

Download using:
```
devtools::install_github("borstell/signglossR")
```

# Introduction
The R package `signglossR` includes various R functions (created, adapted, and imported) that may help sign language researchers work with a visual representation of sign language data (i.e. videos and images). Hopefully, overcoming some of the technical obstacles will encourage more researchers to adopt **\#GlossGesang** and avoid \#TyrannyOfGlossing (see [Glossing](#glossing)). The intention of this package is to collect many different existing resources and adapt them to sign language researchers. The hard work in actual coding has been done by others -- `signglossR` relies heavily on other R packages such as [`magick`](https://ropensci.org/tutorials/magick_tutorial/), [`opencv`](https://docs.ropensci.org/opencv), and [`av`](https://docs.ropensci.org/av/), and also makes use of background command line prompts through R, especially [`ImageMagick`](https://imagemagick.org) and [`ffmpeg`](https://ffmpeg.org).

The section [Images](#images) describes tools for accessing and modifying **image** files, such as downloading still images of signs from online sign language dictionaries, but also modifying such images by cropping or creating overlays, or adding annotated text or automatic or manual censoring/blurring. From version 2.0, it is also possible to work directly with [ELAN](https://archive.mpi.nl/tla/elan) for automated visual glossing and also simply read annotations from `.eaf` files directly into R.

The section [Videos](#videos) describes tools for accessing and modifying **video** files, such as downloading videos of signs from online sign language dictionaries. In versions >=1.1.0, this also includes tools for modifying videos, such as repeating, slowing down, and converting to `.gif`. From version 2.0, it is also possible to work directly with [ELAN](https://archive.mpi.nl/tla/elan) for automated visual glossing. From v2.1.0 it is also possible to download GIFs for STS directly with `get_gif()`.

The section [Miscellaneous](#miscellaneous) describes other functions not directly related to image or video processing.


## Glossing
Glossing has been a standard way of representing sign language data in linguistics research. In practice, this has meant using written word labels in place of signs, such as in this example from the [STS Dictionary](https://teckensprakslexikon.su.se/ord/01913#exempel2):

![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/01913#exempel2)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/videos/meat.gif)

    IX EAT MEAT IX
    'They don't eat meat'
    (Svenskt teckenspråkslexikon 2020, example 01913-2)

This is problematic since [sign languages](#languages) are visual languages, and any written representation of the signs comes with an incredible loss of information: *Which signs are used if there are variants for the same concept?*, *How are signs moving in space?*, *What non-manual signals are present alongside the manual signs?*, etc.

Many sign language researchers are in favor of the concept of [\#GlossGesang](https://twitter.com/hashtag/GlossGesang), named after Julie Hochgesang (a proponent of visual glossing and opponent of the [Tyranny of glossing](https://twitter.com/search?q=tyrannyofglossing)). \#GlossGesang has been tentatively defined as:

* *"Always present sign language data in a visual format (videos/images) without relying solely on glossing."* [(Börstell 2019)](https://twitter.com/c_borstell/status/1177498599992610823)


## Languages
At the time of this first release, the only to languages available for data *downloads* are ASL (American Sign Language) and STS (Swedish Sign Language; *svenskt teckenspråk*). These are chosen out of convenience but also as they both have online lexical resources that are not heavily copyrighted. I have a few more languages lined up, hopefully to be added soon (looking at you FinSL, FinSSL, and NZSL...). However, most functions in `signglossR` can be used with any image/video file, such as those you may already have locally on your computer, from your own dataset. Here, `signglossR` can be used to quickly prepare your data for teaching or presentation slides.

NB: If you use `signglossR` to download data, make sure you cite not only this R package itself but also attribute the original sources of language resources behind the data (see [License](#license)).


## Images
### `get_image()`
This function inputs an  ID number and downloads the image of the corresponding sign entry in the selected language.

Example:
```
get_image(id=10, acronym="sts")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn-00010.jpg)

In this image, the image of BJÖRN ('bear') from STS becomes very wide as there are several frames to represent the sign. We could try to use the `overlay` argument to create an overlay image instead:
```
get_image(id=10, acronym="sts", overlay=TRUE)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn-00010_overlay.jpg)

This did not turn out very nice, since the movement segments get lost in the overlay. We could go back and try to use the `trim` argument, which trims each frame to a factor (0 to 1) of its original width:
```
get_image(id=10, acronym="sts", overlay=FALSE, trim=.8)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn-00010_trimmed.jpg)

(NB: `overlay` and `trim` are currently only available for STS. Below are other options available for ASL.)

Maybe we want to add the text gloss onto the image (text glosses are not all bad, as long as they are accompanied by something more visual, like images/videos!). We can do this by setting the `glosstext` argument to `TRUE`:
```
get_image(id=103, acronym="asl", glosstext=TRUE)
```

Oh no! This didn't turn out very nice! The default anchor point (`gravity`) for the text annotation is `north` (i.e. top middle part of frame), but this part of the image is blocked by the signer here. We can change the `gravity` to something else:
```
get_image(id=103, acronym="asl", glosstext=TRUE, gravity="southwest")
```

This looks better! In other cases, the default `gravity` position may be perfectly fine:
```
get_image(id=103, acronym="asl", glosstext=TRUE, gravity="southwest")
```

## GIFs
### `get_gif()`
This function inputs an  ID number and downloads the GIF of the corresponding sign entry in the selected language (currently only STS.

Example:
```
get_gif(10)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn.gif)


#### Subfunctions
The `get_image()` function passes its arguments onto subfunctions for individual language resources, i.e. `get_image_asl()` and `get_image_sts()`.

### `censor_image()`
Maybe you need to censor part of your image for some reason. Perhaps to hide the identity of the signer. This can be done using the function `censor_image()` which allows you to either blur or completely censor some region of the image. Default `style` is set to `blur`. If `automatic` is set to `FALSE` (default is `TRUE`), you will need to define a geometry region; if set to `TRUE`, the imported function `opencv::ocv_facemask()` will automatically detect faces and use as a mask for blurring/censoring.

```
censor_image(file="STS_taxi-00001.jpg", automatic=TRUE, style="blur")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_taxi-00001_overlay_blurred.jpg)

Through the [`pipe`](#pipe) function, we can download and process videos in a single run. This is actually how the censored example below was generated:

```
get_image(1) %>% 
  censor_image(style="black")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_taxi-00001_overlay_censored.jpg)

The automatic function is particularly useful when there are multiple regions to be censored, as multiple regions can be identified and masked at once. However, the method may fail if the face is covered:

```
get_image(10, acronym="sts", overlay=FALSE) %>% 
  censor_image(style="black")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_bjorn-00010_censored.jpg)

Below are some examples of manually defined regions to censor.

```
censor_image(file=path, automatic=FALSE, region = "100x120+270+60", style="blur")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00001)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/taxi-00001_blurred.jpg)

```
censor_image(file=path, region = "100x120+270+60", method="black")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00001)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/taxi-00001_censored.jpg)

The `region` argument defines *where* the censored rectangle should be, but also of what *size* it should be. The region to be modified defaults to '100x150+100+100', which is defined in [ImageMagick `geometry` syntax](https://www.imagemagick.org/script/command-line-options.php?#geometry) (width x height +upper_x +upper_y).

### `make_image_ex()`
This function is useful for preparing images of signs for e.g. teaching or presentation slides or publications. The function has merged many of the options available in the [`magick`](https://ropensci.org/tutorials/magick_tutorial/) package, and allows you to `crop` and `scale` (i.e. resize) images, but also add text annotations or a border frame:

```
get_image(id, acronym="sts", overlay=TRUE) %>% 
  make_image_ex(text=id2gloss(id), fontsize=45, gravity="northwest", border=TRUE)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/01210)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_varld-01210_EXAMPLE.jpg)

### `combine_images()`
With this function, you can combine several images into one single output image. You can choose between either an `overlay` output image, or one with distinct frames either horizontally aligned (`stack=FALSE`) or stacked vertically (`stack=TRUE`).

If we create a pipeline to generate individual frames, we can get this type of workflow:
```
signs <- c(12747, 1210)
sequence <- c()
for (n in signs) {
   sequence <- c(sequence, make_image_ex(get_image(n, "sts", overlay = T), text=id2gloss(n),
    fontsize = 45, border = T, gravity = "northwest"))

combine_images(sequence, destfile = "./helloworld.jpg", stack=FALSE)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/sok?q=12747%2C1210)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/helloworld.jpg)
```
combine_images(sequence, destfile = "./helloworld.jpg", stack=TRUE)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/sok?q=12747%2C1210)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/helloworld_stacked.jpg)



## Videos

### `get_video()`
This function inputs an  ID number and downloads the video of the corresponding sign entry in the selected language.

Example:
```
get_video(id=10, acronym="sts")
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00010)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn.gif)

NB: This example is shown as a `.gif` even though the actual download will use the video format of the original source (mostly `.mp4`). GIF conversion functionality is available from version 1.1.0 with the function `make_gif()` (see below).

### `make_gif()`
We all love GIFs (hard /g/)! With this function, which uses command line prompts, you can input any video file and it outputs a `.gif` file. You can specify the `scale` of the video dimensions, and the framerate `fps` (it is often smart to downsize a little, as GIFs are often heavy).

```
make_gif(file="STS_dov-00042-tecken.mp4", scale=.5, fps=12.5)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00042)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_dov-00042-tecken.gif)

If you pipe a video download from `get_video()` to `make_gif()`, both video file and gif file will be saved, for example:

```
get_video(42) %>% 
  make_gif(scale=.5, fps=12.5)
  
$ STS_dov-00042-tecken.mp4
$ STS_dov-00042-tecken.gif
```

### `make_video_ex()`
Often when you want to show an example during a presentation etc., you may want to repeat or show a slowed down rendition of the sign. These things can be done with `make_video_ex()` which takes a `speed` (video playback speed) and `rep` (repeat; default is `FALSE`) argument. If `speed` is set to `.7` (=70%), we get a slightly slowed down video output:

```
make_video_ex(file="STS_dov-00042-tecken.mp4", speed=.7)
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_dov-00042-tecken_70.gif)

We could also set the `rep` argument to `TRUE` (or `T` for short), which means that the video example rendered will first play once in normal speed, then repeated once with slower speed, here set to 30% (`speed = .3`):

```
get_video(42) %>% 
  make_video_example(rep=T, speed=.3)
```
![[Svenskt teckenspråkslexikon (2020)](https://teckensprakslexikon.su.se/ord/00042)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/STS_dov-00042-tecken_30_REP.gif)

#### Subfunctions
The `get_video()` function passes its arguments onto subfunctions for individual language resources, i.e. `get_video_asl()` and `get_video_sts()`.


## ELAN functionality
### `read_elan()`
This function reads ELAN annotation files (.eaf) from a directory and outputs a data frame (can be a little slow in case of many files, but the files read should be printed to the console).

### `make_elan_image()`
This function creates image files (with or without text) from an ELAN annotation file.

![[Svensk teckenspråkskorpus (2020)](https://teckensprakskorpus.su.se/#/)](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/elan_image.jpeg)

### `make_elan_video()`
This function creates video file clips (with or without text) from an ELAN annotation file.


## Openpose functionality
### `read_openpose()`
This function reads OpenPose generated JSON files in a directory and outputs a data frame.

### `plot_openpose()`
This function inputs a data frame from `read_openpose(wide=FALSE)` (.eaf) and plots the positions of the hands (keypoints 4 and 7) onto a estimated signer silhouette.

### `make_avatar()`
Mostly for fun, but can estimate a signer based on an Openpose data sequence.


## Miscellaneous
### `cite_source`
Alongside the standard R `citation()` function for citing packages (or R itself), the function `cite_source()` outputs the preferred citation format of the language resource of a language.

Example:
```
> cite_source("asl")

To cite ASL Signbank in publications, please use:

  Julie A. Hochgesang, Onno Crasborn & Diane Lillo-Martin. 2022. ASL Signbank.
  New Haven, CT: Haskins Lab, Yale University.
  https://aslsignbank.haskins.yale.edu/

      (See also: https://aslsignbank.haskins.yale.edu/about/conditions/)

A BibTeX entry for LaTeX users is

@Manual{aslsignbank,
    title = {{ASL Signbank}},
    author = {Julie A. Hochgesang and Onno Crasborn and Diane Lillo-Martin},
    organization = {Haskins Lab, Yale University},
    address = {New Haven, CT},
    year = {2022},
    url = {https://aslsignbank.haskins.yale.edu/}
  }
   
```

### `gloss2id()`
This function takes an ID gloss as its input and returns the sign entry's corresponding ID **number**.

Example:
```
> gloss2id("DEAFix", acronym="asl")
[1] "103"
```
Case is irrelevant:
```
> gloss2id("deafix", acronym="asl")
[1] "103"
```

### `id2gloss()`
This function takes an ID number as its input and returns the sign entry's corresponding ID **gloss**.

Example:
```
> id2gloss(1)
[1] "TAXI(J)"
```
Integer or string is irrelevant:
```
> gloss2id("103", acronym="asl")
[1] "DEAFix"
```

#### Subfunctions
`id2gloss()` and `gloss2id()` call on specific subfunctions per language: `id2gloss_asl()`, `id2gloss_asl()`, `id2gloss_sts()`, `gloss2id_sts()`

### `search_corpus()`
With the function `search_corpus()`, you can input a corpus ID gloss and it takes you directly to the search hits of an online corpus to show you the results. NB: Currently only available for STS:

```
> search_corpus("TAXI(J)")
[1] "https://teckensprakskorpus.su.se/#/?q=TAXI(J)"
```


### Other
Small functions that only serve to assist other functions.

### `pipe`
This function enables the use of piping with `%>%` (originally from the [`magrittr`](https://magrittr.tidyverse.org) package, well known from [`tidyverse`](https://www.tidyverse.org)).

Example:
```
get_image(1, acronym="sts", overlay=TRUE) %>% 
  censor_image(region = "100x120+270+60")
```

#### `isNotNumeric()`
For checking inputs.


## Logo
The logo was created by me using a combination of own code for reading images and plotting them in [`ggplot2`](https://ggplot2.tidyverse.org). The hex sticker is a nod to the [`tidyverse`](https://www.tidyverse.org) logos and was rendered using the [`hexSticker`](https://github.com/GuangchuangYu/hexSticker) package. The color is turquoise which is a color that I like and also relates to the deaf world. The motif is chosen because it is an **iconic** image of hands, and also because the two hands almost form G handshapes (in many one-handed manual alphabets). And the `gg` structure reminds me of both R packages in `tidyverse`, but also the concept of \#GlossGesang!

<img src="https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/sticker_signglossR.png" width="200">

## License
* This R package can be used, modified, and shared freely under the [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/). 

* Please acknowledge any use of the `signglossR` package. The preferred citation is given by the ```citation("signglossR")``` function:

* Do cite the original sources when using any material downloaded by `signglossR`. The preferred citations for these can be found using the `signglossR` function `cite_source()` which takes the sign language acronym of the language resource in question as its only argument (e.g. `cite_source("asl")`).

```
citation("signglossR")

To cite reports in publications, please use:

  Börstell, Carl. 2022. signglossR: Facilitating visual representation of sign
  language data. R package version 2.2.2. University of Bergen.
  https://github.com/borstell/signglossR

A BibTeX entry for LaTeX users is

@Manual{signglossR,
    title = {{signglossR}: Facilitating visual representation of sign language data},
    author = {Carl Börstell},
    organization = {University of Bergen},
    address = {Bergen},
    note = {R package version 2.2.2},
    year = {2022},
    url = {https://github.com/borstell/signglossR},
  }
```

![[License: CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)](https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-nc-sa.png)
