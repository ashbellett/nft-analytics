library("dplyr")
library("tidyr")


transactions <- read.csv(
    paste0(Sys.getenv("DATA_RAW"), Sys.getenv("DATA_FILE")),
    colClasses=c(
        hash="character",
        blockNumber="character",
        from="character",
        to="character",
        tokenID="integer",
        tokenName="character",
        gas="numeric",
        gasPrice="numeric",
        gasUsed="numeric",
        value="numeric"
    )) %>%
    select(
        hash,
        blockNumber,
        timeStamp,
        from,
        to,
        tokenID,
        tokenName,
        gas,
        gasPrice,
        gasUsed,
        value
    ) %>%
    mutate(timeStamp=as.Date(as.POSIXct(strtoi(timeStamp), origin="1970-01-01")))

write.csv(
    transactions,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TRANSACTIONS")),
    row.names=FALSE
)
