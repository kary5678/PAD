# Retrieve ID numbers from pasted message 

char_ids <- strsplit("
    [6659] 火車の式神使い・セイナ
    [6660] 恩讐の退魔師・セイナ
    [6661] アゴウの式札
    [6662] 赫龍の式神使い・リュウメイ
    [6663] 去私の退魔師・リュウメイ", split="\\D+")
num_ids <- as.numeric(char_ids[[1]][-1])
num_ids
View(data.frame(ID=num_ids))