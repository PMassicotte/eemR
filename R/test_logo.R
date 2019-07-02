library(hexSticker)
library(tidyverse)
library(eemR)

file <- "D:/work-ulaval/projects/huixiang/fluorescence_low_oxygen_bohai/matlab/Model6.txt"

data.table::fread(file, skip = 23)

df <- read_delim(file, skip = 23, delim = "\t", col_names = c("type", "wavelength", paste0("comp", 1:7))) %>%
  select(-comp7) %>%
  gather(component, intensity, -type, -wavelength) %>%
  filter(component == "comp2")

plot_component <- function(df2, component) {

  em <- df2$wavelength[df2$type == "Em"]
  ex <- df2$wavelength[df2$type == "Ex"]
  x <- df2$intensity[df2$type == "Ex"] %*% t(df2$intensity[df2$type == "Em"])

  emm <- seq(min(em), max(em), by = 0.5)
  exx <- seq(min(ex), max(ex), by = 0.5)

  R <- akima::interp(rep(ex, length(em)), rep(em, each=length(ex)), x, exx, emm)

  res <- crossing(ex = R$x, em = R$y) %>%
    mutate(intensity = as.vector(t(R$z))) %>%
    mutate(intensity = ifelse(intensity <= 0, 0, intensity))

  brks <- cut(res$intensity, seq(0, max(res$intensity), len = 7), include.lowest = TRUE)
  brks <- gsub(",", "-", brks, fixed = TRUE)
  res$brks <- gsub("\\(|\\]|\\[", "", brks)  # reformat guide labels

  p1 <- res %>%
    ggplot(aes(x = ex, y = em, fill = brks, z = intensity)) +
    geom_raster() +
    # facet_wrap(~component, scales = "free") +
    scale_fill_manual("Fluorescence intensity (R.U.)", values = viridis::viridis(7)) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    # coord_fixed() +
    guides(fill = guide_legend(reverse = TRUE)) +
    theme(legend.position = "none") +
    xlab(NULL) +
    ylab(NULL) +
    theme(text = element_text(size = 8)) +
    theme(axis.title = element_blank()) +
    theme(axis.text = element_blank()) +
    theme(axis.ticks = element_blank())



  return(p1)

}

res <- df %>%
  group_by(component) %>%
  nest()

p <- map2(res$data, res$component, plot_component)
p
ggsave("c:/Users/pmass/Desktop/test.pdf", device = cairo_pdf)

