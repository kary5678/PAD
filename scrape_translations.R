# Scrape English monster name translations from Reddit
library(stringr)
library(XML)
library(dplyr)

download.file("https://www.reddit.com/r/PuzzleAndDragons/wiki/ryulong/list2", destfile = "ryulong_names.html")
doc <- htmlParse("ryulong_names.html")
names_string <- as(doc, "character")
location1 <- str_locate(names_string,'This is page 2 of the list, continued from <a href="/r/PuzzleAndDragons/wiki/ryulong/list" rel="nofollow">page 1</a>.</p>
<ul>')
location2 <- str_locate(names_string,'</ul>
<h1 id="wiki_tba">TBA</h1>')
data <- str_sub(names_string,location1[2],location2[1]) #subset to just the translation data

row_entries <- strsplit(data, split="</li>\n<li>")[[1]] #separate each monster to their own line
id_2names <- unlist(strsplit(row_entries, split="(?<=\\d{4})\\. ", perl=TRUE)) #split id and combined na+jp name
df <- as.data.frame(matrix(id_2names, ncol=2, byrow=TRUE)) #all of the data...
df2 <- subset(df, V2!="?" & V2!="? [Original Art Lina]") #remove entries that haven't been translated/added
df2$V2 <- str_replace(df2$V2, "&amp;", "&") #adjust text formatting

#extract numeric ids from new_card_announce post, replace text for each wave of new cards
char_ids <- strsplit("
    [6998] 至福の魔女・ポンノ
    [6999] バレンタインの双魚神・アルレシャ
    [7000] 怪しいバレンタインチョコレート", split="\\s+")[[1]][-1]

dff <- as.data.frame(matrix(char_ids, ncol=2, byrow=TRUE))
dff$V1 <- str_replace(dff$V1, "\\[", "")
dff$V1 <- str_replace(dff$V1, "\\]", "")
df3 <- subset(df2, V1 %in% dff$V1) #subset scraped data with translations to those of interest

#split na+jp name into na and jp fields
na_jp_strings <- unlist(str_split(df3$V2, pattern="\\((?=[^(]+$)")) #split original single string with both names
na_jp_names <- as.data.frame(matrix(na_jp_strings, ncol=2, byrow=TRUE))
df3$V2 <- na_jp_names$V1
df3$V3 <- na_jp_names$V2

#merge new_card_announce stuff (dff) with relevant scraped to check
final <- full_join(dff, df3, by="V1")
final <- final[colnames(final)[c(1,3,2,4)]]
colnames(final) <- c("id", "en_scraped", "jp_official", "jp_scraped")
final$en_scraped <- str_replace(final$en_scraped, "\\[", "") #beware formatting of some cards, e.g. GH Collab
final$en_scraped <- str_replace(final$en_scraped, "\\]", "")
#final <- subset(final, !is.na(en_scraped)) #easier for copy paste

View(final) #final data table to double check work
nrow(dff) #number of new cards
nrow(df3) #check to see if it matches up with amount scraped
cat(paste("^credit", final$id, final$en_scraped), sep="\n") #output to console
