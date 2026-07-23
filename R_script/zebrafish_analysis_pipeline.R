# Section 1: Environment Setup & Library Loading
library(tidyverse)
library(dplyr)
library(GEOquery)
library(ggplot2)


# Section 2: Data Loading & Metadata Parsing (GEOquery)
dat<- read.csv(file = "../Data1/GSE338160_tablecounts_raw.csv")
dim(dat)


# Get the metadata
 gse<- getGEO(GEO ='GSE338160',GSEMatrix = TRUE  )
 
 
metadata<- pData(phenoData(gse[[1]]))

head(metadata)


metadata.subset<- select(metadata,c(1,17,39))
    
    
head(metadata.subset)


metadata.modified<- metadata %>% select(1,17,39) %>% rename(type = "sample group:ch1") %>% mutate(description = gsub("Library name: ","",description)) 





# Section 3: Data Wrangling & Long-to-Wide Reshaping
data.long<- dat%>% rename(Gene= X) %>% gather(key="samples",value="values", - Gene)




# Join data frames = data.long+metadata.modified
data.long<- data.long%>% left_join(.,metadata.modified, by= c("samples"= "description"))  

colSums(is.na(data.long))




# Section 4: Exploratory Data Analysis & Summary Statistics
DATA_RESULTS<- data.long %>%
    filter(Gene %in% c("il22", "il26", "pcna", "stat3")) %>%
    group_by(Gene, type) %>%
    summarize(
        n = n(),
        mean_val = mean(values),
        median_val = median(values),
        sd_val = sd(values),
        min_val = min(values),
        max_val = max(values)
    )%>% arrange(mean_val)




# Data visualization
# ggplot(data,aes(x,y)) +geom_



# Bar plot
#data.long %>%  filter(Gene == "il22") %>% ggplot(.,aes(x=samples,y=values))+geom_col()
#data.long %>%  filter(Gene == "il22") %>% ggplot(.,aes(x=type,y=values))+geom_col()

data.long %>%  
    filter(Gene == "il22") %>% 
    ggplot(., aes(x = interaction(samples,type, sep=": "), y = values,fill=type)) + 
    geom_col()

ggsave("il22_barplot.png", width = 8, height = 6, dpi = 300)

# Density plot

data.long %>%  
    filter(Gene == "il22") %>% 
    ggplot(., aes(x =  values,fill=type)) + 
    geom_density(alpha = 0.3)

ggsave("il22_density.png", width = 8, height = 6, dpi = 300)

# Box plot

data.long %>%  
    filter(Gene == "il22") %>% 
    ggplot(., aes(x =  type,y=values, fill=type)) + 
    geom_boxplot()

ggsave("il22_boxplott.png", width = 8, height = 6, dpi = 300)

# Scatter plot

data.long %>%  
    filter(Gene == "il22"| Gene== "stat3") %>%  spread(key = Gene, value = values)%>% ggplot(., aes(x = il22,y=stat3, color= type)) + 
    geom_point() +geom_smooth(method = "lm", se=FALSE)


ggsave("il22_stat3_scatterplot.png", width = 8, height = 6, dpi = 300)




# Heat map
# Selecting genes of interest
genes.of.interest<- c("il22","il26","pcna","stat3")

# creating the map
data.long %>%  
    filter(Gene %in% genes.of.interest) %>% 
    ggplot(., aes(x = samples,y=Gene, fill=values)) + 
    geom_tile() +scale_fill_gradient(low="grey",high = "red")

ggsave("gene_expression_heatmap.png", width = 8, height = 6, dpi = 300)
