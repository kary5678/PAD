# Generate a string of characters to paste into Dawnglare
# Attributes can be selected, but they will be sampled from with the same probabilities

# Select the size of the board to simulate
boardSelection <- utils::menu(c("6x5", "7x6", "5x4"), title="What is the board size?")

numOrbs <- ifelse(boardSelection==1, yes=30, no=
                    ifelse(boardSelection==2, yes=42, no=20))

# What are the valid colors in the pool to sample from equally?
orbAttSelection <- readline(prompt="Enter orb types: ")

numAtts <- nchar(orbAttSelection)
orbAtts <- unlist(stringr::str_split(orbAttSelection, pattern="", n=Inf))

# Get the pattern text to paste into Dawnglare
paste(sample(orbAtts, numOrbs, replace=TRUE), collapse="")
