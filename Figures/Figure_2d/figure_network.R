# 
# Script to produce a nice graph figure 
# 

library(readxl)
library(plyr)
library(ggraph)
library(igraph)

y <- as.data.frame(read_excel("Intertidal foodweb.xls",
                              sheet = 1, col_names = TRUE)[ ,-1])
ynames <- as.data.frame(read_excel("Intertidal foodweb.xls",
                                   sheet = 2, col_names = TRUE))
node_attribs <- 
  as.data.frame(read_excel("SpeciesCharacteristics.xlsx", sheet = 1))

# Massage network data
ylong <- data.frame(expand.grid(spi = seq.int(ncol(y)), 
                                spj = seq.int(ncol(y))), 
                    y   = as.vector(as.matrix(y)))
ylong[ ,"spi"] <- gsub("'", "", ynames[ylong[ ,"spi"], "SpeciesName"])
ylong[ ,"spj"] <- gsub("'", "", ynames[ylong[ ,"spj"], "SpeciesName"])
ylong <- subset(ylong, y > 0)

# Merge with species attributes 
nodes <- data.frame(spi = unique(c(ylong[ ,"spi"], ylong[ ,"spj"])))
nodes <- join(nodes, mutate(node_attribs, spi = label), 
              type = "left", match = "first", by = "spi")

# Fix data where Lessonia adult is linked to all the links of Lessonia young 
ylong <- subset(ylong, { 
  spj != "lessonia nigrescens a" | 
    ( spj == "lessonia nigrescens a" & spi == "scurria scurra" ) 
})

library(ggraph)
library(igraph)

# Create graph object 
graph <- graph_from_data_frame(ylong, directed = TRUE, vertices = nodes)

# Some trophic levels are missing, so we add them here
V(graph)$TL[V(graph) == "parantheopsis"] <- "Omnivore"
V(graph)$TL[V(graph)$name == "plankton"] <- "Plankton"

# Create layout 
ylevels <- c(producers = 0, herbivore = 1, filter = 0.5, omnivore = 2, predator = 3, 
             top = 4)
set.seed(122)
x <- runif(length(V(graph)), 0, 1)
y <- rnorm(length(V(graph)), ylevels[tolower(V(graph)$TL)], .1)

# Swap Parantheopsis and Plankton
# <todo>
plankton_xy      <- which(names(V(graph)) == "plankton"        )
parantheopsis_xy <- which(names(V(graph)) == "parantheopsis "  )

tmpx <- x[parantheopsis_xy]
tmpy <- y[parantheopsis_xy]
x[parantheopsis_xy] <- x[plankton_xy]
y[parantheopsis_xy] <- y[plankton_xy]
x[plankton_xy] <- tmpx
y[plankton_xy] <- min(y, na.rm = TRUE) + 0.05


y <- ifelse(is.na(y), 0.5, y)

ucw <- function(x) { 
  paste0(toupper(substr(x, 1, 1)), substr(tolower(x), 2, nchar(x)))
}
norm_names <- function(x) { 
  # Normalize species names
  if ( length(x) > 1 ) { 
    return( unlist(lapply(x, norm_names)) ) 
  }
  x <- gsub("^ ", "",  gsub(" $", "", x))
  x <- gsub("  ", " ", gsub(" $", "", x))
  
  if ( grepl("sp(|p).$", x) ) { 
    x <- ucw(x) 
  } else { 
    split <- strsplit(x, " ")[[1]]
    if ( length(split) > 1 ) { 
      x <- paste0(ucw(substr(split[1], 1, 1)), ". ", split[2:length(split)], 
                  collapse = " ")
    } else { 
      x <- ucw(x)
    }
  }
  
  return(x)
}

# Show only some nodes 
shown_nodes <- c("gulls", "scurria scurra", "chiton granosus", "tegula atra", 
                 "plankton", "algae", "lessonia nigrescens j", 
                 "lessonia nigrescens a")

ggraph(graph, layout = data.frame(x = x, y = y)) + 
  geom_edge_bend2(aes(color = node.TL), 
                 alpha = 0.8, strength = 0.2) + 
  geom_node_point(aes(size = degree(graph), fill = TL), 
                  shape = 21) + 
#   geom_node_text(aes(label = ifelse(name %in% shown_nodes, name, NA)), 
  geom_node_text(aes(label = norm_names(name)), repel = TRUE, size = 3) + 
  theme_void() + 
  scale_size(guide = "none") + 
  scale_edge_color_discrete(guide = "none") + 
  scale_fill_discrete(name = "Trophic\nlevel") + 
  guides(fill = guide_legend(override.aes = list(size = 4)))





ggsave("figure_network.pdf", width = 8, height = 6)

