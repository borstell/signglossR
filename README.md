<img src="https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/sticker_signglossR.png" width="600">

# signglossR
An R package that facilitates *visual* representation of sign language data

Download using:
```
devtools::install_github("borstell/signglossR")
```

# Introduction
The R package `signglossR` includes various R functions (created, adapted, and imported) that may help sign language researchers work with a visual representation of sign language data (i.e. videos and images). Hopefully, overcoming some of the technical obstacles will encourage more researchers to adopt **\#GlossGesang** and avoid \#TyrannyOfGlossing (see [Glossing](#glossing-glossing)).

The section [Images](#images-images) describes tools for accessing and modifying **image** files, such as downloading still images of signs from online sign language dictionaries, but also modifying such images by cropping or creating overlays, or adding annotated text or censor blurring.

The section [Videos](#videos-videos) describes tools for accessing and modifying **video** files, such as downloading videos of signs from online sign language dictionaries. ~~[TBA: This will also include tools for modifying videos, such as repeating, slowing down, and cropping, and preferably also interacting directly with [ELAN](https://archive.mpi.nl/tla/elan)] for automated visual glossing.]~~

## Glossing {#glossing}
Glossing has been a standard way of representing sign language data in linguistics research. In practice, this has meant using written word labels in place of signs, such as in this example from the [STS Dictionary](https://teckensprakslexikon.su.se/ord/01913#exempel2):

![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/videos/meat.gif)

    IX EAT MEAT IX
    'They don't eat meat'
    (Svenskt teckenspråkslexikon 2020, example 01913-2)

This is problematic since [sign languages](#languages) are visual languages, and any written representation of the signs comes with an incredible loss of information: *Which signs are used if there are variants for the same concept?*, *How are signs moving in space?*, *What non-manual signals are present alongside the manual signs?*, etc.

Many deaf and hearing researchers are in favor of the concept of [\#GlossGesang](https://twitter.com/hashtag/GlossGesang), named after Julie Hochgesang (a proponent of visual glossing and opponent of the [Tyranny of glossing](https://twitter.com/search?q=tyrannyofglossing)). \#GlossGesang has been tentatively defined as:

* *"Always present sign language data in a visual format (videos/images) without relying solely on glossing."* [(Börstell 2019)](https://twitter.com/c_borstell/status/1177498599992610823)

## Languages
At the time of this very first release, the only to languages available are ASL (American Sign Language) and STS (Swedish Sign Language; *svenskt teckenspråk*). These are chosen out of convenience but also as they both have online lexical resources that are not heavily copyrighted. I have a few more languages lined up, hopefully to be added soon (looking at you FinSL, FinSSL, and NZSL...). If you use `signglossR`, make sure you cite not only this R package itself but also attribute the original sources of language resources behind the data (see [License and use](#license)).

## Images
### `get_image()`
This function inputs an  ID number and downloads the image of the corresponding sign entry in the selected language.

Example:
```
get_image(id=1, acronym="sts")
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn-00010.jpg)

In this image, the image of BJÖRN ('bear') from STS becomes very wide as there are several frames to represent the sign. We could try to use the `overlay` argument to create an overlay image instead:
```
get_image(id=1, acronym="sts", overlay=TRUE)
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn-00010_overlay.jpg)

This did not turn out very nice, since the movement segments get lost in the overlay. We could go back and try to use the `trim` argument, which trims each frame to a factor (0 to 1) of its original width:
```
get_image(id=1, acronym="sts", overlay=FALSE, trim=.8)
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn-00010_trimmed.jpg)

(NB: `overlay` and `trim` are currently only available for STS. Below are other options available for ASL.)

Maybe we want to add the text gloss onto the image (text glosses are not all bad, as long as they are accompanied by something more visual, like images/videos!). We can do this by setting the `glosstext` argument to `TRUE`:
```
get_image(id=103, acronym="asl", glosstext=TRUE)
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/ASL_DEAF-103_badtext.jpg)

Oh no! This didn't turn out very nice! The default anchor point (`gravity`) for the text annotation is `north` (i.e. top middle part of frame), but this part of the image is blocked by the signer here. We can change the `gravity` to something else:
```
get_image(id=103, acronym="asl", glosstext=TRUE, gravity="southwest")
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/ASL_DEAF-103.jpg)

This looks better! In other cases, the default `gravity` position may be perfectly fine:
```
get_image(id=103, acronym="asl", glosstext=TRUE, gravity="southwest")
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/ASL_DEAF-104.jpg)

#### Subfunctions
The `get_sign()` function passes its arguments onto subfunctions for individual language resources, i.e. `get_sign_asl()` and `get_sign_sts()`.

### `censor_image()`
Maybe you need to censor part of your image for some reason. Perhaps to hide the identity of the signer. This can be done using the function `censor_image()` which allows you to either blur or completely censor some region of the image. Default `method` is set to `blur`:
```
censor_image(region = "100x120+270+60", method="blur")
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/taxi-00001_blurred.jpg)

```
censor_image(region = "100x120+270+60", method="black")
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/taxi-00001_censored.jpg)

The `region` argument defines *where* the censored rectangle should be, but also of what *size* it should be. The region to be modified defaults to '100x150+100+100', which is defined in [ImageMagick `geometry` syntax](https://www.imagemagick.org/script/command-line-options.php?#geometry) (width x height +upper_x +upper_y).

Through the [`pipe`](#pipe) function, we can download and process videos in a single run. This is actually how the blurred example above was generated:
```
get_image(1, acronym="sts", overlay=TRUE) %>% 
  censor_image(region = "100x120+270+60")
```

### ~~`elan2image()`~~

## Videos {#videos}

### `get_video()`
This function inputs an  ID number and downloads the video of the corresponding sign entry in the selected language.

Example:
```
get_image(id=10, acronym="sts")
```
![](https://raw.githubusercontent.com/borstell/borstell.github.io/master/images/bjorn.gif)

(NB: This example is shown as a `.gif even though the actual download will use the video format of the original source (mostly `.mp4`). GIF conversion functionality is not yet available, but will hopefully come in a later release soon.)

#### Subfunctions
The `get_video()` function passes its arguments onto subfunctions for individual language resources, i.e. `get_video_asl()` and `get_video_sts()`.

### ~~`get_gif()`~~

### ~~`make_slowmotion()`~~

### ~~`elan2video()`~~

## Miscellaneous {#miscellaneous}
### `cite_source`
Alongside the standard R `citation()` function for citing packages (or R itself), the function `cite_source()` outputs the preferred citation format of the language resource of a language.

Example:
```
> cite_source("asl")

To cite ASL Signbank in publications, please use:

  Julie A. Hochgesang, Onno Crasborn & Diane Lillo-Martin. 2020. ASL Signbank.
  New Haven, CT: Haskins Lab, Yale University.
  https://aslsignbank.haskins.yale.edu/

      (See also: https://aslsignbank.haskins.yale.edu/about/conditions/)

A BibTeX entry for LaTeX users is

@Manual{aslsignbank,
    title = {{ASL Signbank}},
    author = {Julie A. Hochgesang and Onno Crasborn and Diane Lillo-Martin},
    organization = {Haskins Lab, Yale University},
    address = {New Haven, CT},
    year = {2020},
    url = {https://aslsignbank.haskins.yale.edu/}
  }
   
```

### `gloss2id_asl()` {#gloss2id}
This function takes an ASL Signbank ID gloss as its input and returns the sign entry's corresponding ID **number**.

Example:
```
> gloss2id_asl("DEAFix")

"103"
```
Case is irrelevant:
```
> gloss2id_asl("deafix")

"103"
```

### `id2gloss_asl()`
This function takes an ASL Signbank ID numbers as its input and returns the sign entry's corresponding ID **gloss**.

Example:
```
> id2gloss_asl(103)
[1] "DEAFix"
```
Integer or string is irrelevant:
```
> gloss2id_asl("103")
[1] "DEAFix"
```

### `pipe` {#pipe} 
This function enables the use of piping with `%>%` (originally from the [`magrittr`](https://magrittr.tidyverse.org) package, well known from [`tidyverse`](https://www.tidyverse.org)).

Example:
```
get_image(1, acronym="sts", overlay=TRUE) %>% 
  censor_image(region = "100x120+270+60")
```

### Other {#other}
Small functions that only serve to assist other functions.

#### `isNumeric()`
For checking inputs.

#### `notNumeric()`
For checking inputs.

#### `sts_padding()`
Adds leading zeros to sign ID inputs for STS.

Example:
```
> sts_padding(id=1)
[1] "00001"
```

## License and use {#license}
* This R package can be used, modified, and shared freely under the [CC BY-NC-SA 4.0 license](https://creativecommons.org/licenses/by-nc-sa/4.0/). 

* Please acknowledge any use of the `signglossR` package. The preferred citation is given by the ```citation("signglossR")``` function:

* Do cite the original sources when using any material downloaded by `signglossR`. The preferred citations for these can be found using the `signglossR` function `cite_source()` which takes the sign language acronym of the language resource in question as its only argument (e.g. `cite_source("asl")`).

```
citation("signglossR")

To cite reports in publications, please use:

  Börstell, Carl. 2020. signglossR: Facilitating visual representation of sign
  language data. R package version 1.0.0. Radboud University, Nijmegen.
  https://github.com/borstell/signglossR

A BibTeX entry for LaTeX users is

@Manual{signglossR,
    title = {{signglossR}: Facilitating visual representation of sign language data},
    author = {Carl Börstell},
    organization = {Radboud University, Nijmegen},
    address = {Nijmegen},
    note = {R package version 1.0.0},
    year = {2020},
    url = {https://github.com/borstell/signglossR},
  }
```

![[License: CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)](https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by-nc-sa.png)
