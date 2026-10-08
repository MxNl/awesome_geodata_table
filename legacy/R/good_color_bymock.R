make_color_pal <- function(colors, bias = 1) {
  get_color <- colorRamp(colors, bias = bias)
  function(x) rgb(get_color(x), maxColorValue = 255)
}
good_color_bymock <- make_color_pal(c("#f2fbd2", "#c9ecb4", "#93d3ab", "#35b0ab"), bias = 2)
