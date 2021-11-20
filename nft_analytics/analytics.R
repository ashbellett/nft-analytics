library("dplyr")
library("lubridate")
library("tidyr")
library("zoo")


transactions <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TRANSACTIONS")),
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
    mutate(timeStamp=as.Date(timeStamp))

transfers <- transactions[transactions$value > 0,]

transfersSortedByToken <- arrange(transfers, tokenID, timeStamp)

transfersByDate <- transfers %>%
    group_by(timeStamp) %>%
    summarise(
        transferCount=n(),
        valueMean=mean(value),
        valueStandardDeviation=sd(value),
        valueSum=sum(value),
        gasMean=mean(gas)
    ) %>%
    mutate(valueCumulativeSum=cumsum(valueSum))

transfersByWeek <- transfers %>%
    group_by(week=week(timeStamp)) %>%
    summarise(
        floor=min(value),
        ceiling=max(value)
    ) %>%
    mutate(
        week=ymd("2021-01-01")+weeks(week-1)
    )

uniqueOwnerCounts <- data.frame(
    timeStamp=as.Date(character()),
    uniqueOwnerCount=integer()
)

for (row in 1:nrow(transfers)) {
    timeStamp <- transfers[row, "timeStamp"]
    data <- transfers[1:row, "to"]
    uniqueOwnerCount <- length(unique(data))
    uniqueOwnerCounts[row, "timeStamp"] = timeStamp
    uniqueOwnerCounts[row, "uniqueOwnerCount"] = uniqueOwnerCount
}

uniqueOwnerCounts <- uniqueOwnerCounts %>%
    group_by(timeStamp) %>%
    summarise(uniqueOwnerCount = max(uniqueOwnerCount))

tokenTransferDurations <- data.frame(
    timeStamp=as.Date(character()),
    tokenID=integer(),
    tokenTransferDuration=numeric()
)

for (token in unique(transfersSortedByToken$tokenID)) {
    tokenTransfers <- transfersSortedByToken[transfersSortedByToken$tokenID == token,]
    if (nrow(tokenTransfers) > 1) {
        tokenSingleTransferDurations <- data.frame(
            timeStamp=as.Date(character()),
            tokenID=integer(),
            tokenTransferDuration=numeric()
        )
        for (row in 1:(nrow(tokenTransfers)-1)) {
            tokenSingleTransferDurations[row, "timeStamp"] <- tokenTransfers[row+1, "timeStamp"]
            tokenSingleTransferDurations[row, "tokenID"] <- token
            tokenSingleTransferDurations[row, "tokenTransferDuration"] <- tokenTransfers[row+1, "timeStamp"] - tokenTransfers[row, "timeStamp"]
        }
        tokenTransferDurations <- rbind(tokenTransferDurations, tokenSingleTransferDurations)
    }
}

tokenTransferDurations <- arrange(tokenTransferDurations, timeStamp, tokenID)

tokenTransferDurations <- tokenTransferDurations %>%
    group_by(timeStamp) %>%
    summarise(tokenTransferDuration = mean(tokenTransferDuration))

tokens <- data.frame(
    address=character(),
    tokenID=integer(),
    tokenValue=numeric()
)

for (token in unique(transfersSortedByToken$tokenID)) {
    tokenTransfers <- transfersSortedByToken[transfersSortedByToken$tokenID == token,]
    lastTransfer <- tail(tokenTransfers, 1)
    currentToken <- data.frame(
        address=character(),
        tokenID=integer(),
        tokenValue=numeric()
    )
    currentToken[1, "address"] <- substr(lastTransfer[1, "to"], 1, 10)
    currentToken[1, "tokenID"] <- token
    currentToken[1, "tokenValue"] <- lastTransfer[1, "value"]
    tokens <- rbind(tokens, currentToken)
}

owners <- tokens %>%
    group_by(address) %>%
    summarise(count=n(), sum=sum(tokenValue))


write.csv(
    transfersByDate,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TRANSFERS")),
    row.names=FALSE
)

write.csv(
    transfersByWeek,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TRANSFERS_WEEKLY")),
    row.names=FALSE
)

write.csv(
    uniqueOwnerCounts,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("UNIQUE_OWNERS")),
    row.names=FALSE
)

write.csv(
    tokenTransferDurations,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("DURATIONS")),
    row.names=FALSE
)

write.csv(
    tokens,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TOKENS")),
    row.names=FALSE
)

write.csv(
    owners,
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("OWNERS")),
    row.names=FALSE
)
