# An optional custom script to run before Hugo builds your site.
# You can delete it if you do not need it.
library(leaflet)
library(tidyverse)
library(htmlwidgets)
library(yaml)

place_locs <- list.dirs("./content/places", recursive = FALSE)
place_titles <- str_split_fixed(place_locs, "/", 4)[,4]
place_html <- str_c(place_locs, "/index.md")
names(place_html) <- place_titles
place_yaml <- lapply(place_html, function(x){
    read_yaml(x)
})

place_df <- bind_rows(lapply(place_yaml, function(z){
    tibble(lat = z$lat, lon = z$lon, title = z$title, img = z$images[[1]]$image)
    })) %>%
    mutate(source = str_remove(place_locs, "./content")) %>%
    mutate(img_source = str_c(source, "/", img)) %>%
    mutate(post_link = str_c(
        '<center>',
        '<img src="', img_source, '", width="150" height="150"><br>',
        '<h2><a href = "', source, '" target="_parent">', title, '</a></h2>',
        '</center>'))

base_map <- leaflet(data = place_df) %>%
    addTiles() %>%
    addMarkers(~lon, ~lat, popup = ~post_link)

saveWidget(
    base_map,
    "./themes/hugo-theme-console/static/hugo-theme-console/leaflet/leaflet.html")
