# Scrape English monster name translations from Reddit
library(stringr)
library(XML)
library(dplyr)

download.file("https://www.reddit.com/r/PuzzleAndDragons/wiki/ryulong/list2/", destfile = "ryulong_names.html")
doc <- htmlParse("ryulong_names.html")
names_string <- as(doc, "character")
location1 <- str_locate(names_string,'This is page 2 of the list, continued from <a href="/r/PuzzleAndDragons/wiki/ryulong/list" rel="nofollow">page 1</a>.</p>
<ul>')
location2 <- str_locate(names_string,'</ul>
<h1 id="wiki_tba">TBA</h1>')
data <- str_sub(names_string,location1[2],location2[1]) #subset to just the translation data

row_entries <- strsplit(data, split="</li>\n<li>")[[1]] #separate each monster to their own line
id_names <- unlist(strsplit(row_entries, split="(?<=\\d{4})\\. ", perl=TRUE)) #split id and combined na+jp name
all_data_df <- as.data.frame(matrix(id_names, ncol=2, byrow=TRUE))
all_data_df2 <- subset(all_data_df, V2!="?" & V2!="? [Original Art Lina]") #remove entries that haven't been translated/added
all_data_df2$V2 <- str_replace_all(all_data_df2$V2, "&amp;", "&") #adjust text formatting

#extract numeric ids from new_card_announce post, replace text for each wave of new cards
new_cards <- strsplit("
    [9059] 極醒の紅魔王・パイモン
    [9060] 極醒の冥魔王・パイモン", split="\n")[[1]][-1]

new_cards_df <- as.data.frame(matrix(unlist(str_split(new_cards, pattern="\\]", n=2)), ncol=2, byrow=TRUE))
new_cards_df$V1 <- str_replace_all(new_cards_df$V1, "[^0-9]", "")
translated <- subset(all_data_df2, V1 %in% new_cards_df$V1) #subset scraped data with translations to those of interest

#split na+jp name into na and jp fields
na_jp_strings <- unlist(str_split(translated$V2, pattern="\\((?=[^(]+$)")) #split original single string with both names
na_jp_names <- as.data.frame(matrix(na_jp_strings, ncol=2, byrow=TRUE))
translated$V2 <- na_jp_names$V1
translated$V3 <- na_jp_names$V2

#merge new_card_announce stuff (new_cards_df) with relevant scraped to check
final <- full_join(new_cards_df, translated, by="V1")
final <- final[colnames(final)[c(1,3,2,4)]]
colnames(final) <- c("id", "en_scraped", "jp_official", "jp_scraped")
final$en_scraped <- str_replace(final$en_scraped, "\\[", "") #remove brackets surrounding uncertain translations
final$en_scraped <- str_replace(final$en_scraped, "\\]", "") #but beware formatting of some cards, e.g. GH Collab
#final <- subset(final, !is.na(en_scraped)) #easier for copy paste

View(final) #final data table to double check work
nrow(new_cards_df) #number of new cards
nrow(translated) #check to see if it matches up with amount scraped
cat(paste("^credit", final$id, final$en_scraped), sep="\n") #output lines for pasting to console
