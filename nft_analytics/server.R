library("dplyr")
library("ggplot2")
library("shiny")


transfersByDate <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TRANSFERS")),
    colClasses=c(
        transferCount="integer",
        valueMean="numeric",
        valueStandardDeviation="numeric",
        valueSum="numeric",
        valueCumulativeSum="numeric"
    )) %>%
    mutate(timeStamp=as.Date(timeStamp))

transfersByWeek <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TRANSFERS_WEEKLY")),
    colClasses=c(
        floor="numeric",
        ceiling="numeric"
    )) %>%
    mutate(week=as.Date(week))

uniqueOwnerCounts <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("UNIQUE_OWNERS")),
    colClasses=c(
        uniqueOwnerCount="integer"
    )) %>%
    mutate(timeStamp=as.Date(timeStamp))

tokenTransferDurations <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("DURATIONS")),
    colClasses=c(
        tokenTransferDuration="numeric"
    )) %>%
    mutate(timeStamp=as.Date(timeStamp))

tokens <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("TOKENS")),
    colClasses=c(
        address="character",
        tokenID="integer",
        tokenValue="numeric"
    )
)

owners <- read.csv(
    paste0(Sys.getenv("DATA_RESULTS"), Sys.getenv("OWNERS")),
    colClasses=c(
        address="character",
        count="integer",
        sum="numeric"
    )
)


xDays <- transfersByDate$timeStamp
xWeeks <- transfersByWeek$week

yMeans <- transfersByDate$valueMean/1e18
dataMeans <- data.frame(xDays, yMeans)

yStandardDeviations <- transfersByDate$valueStandardDeviation/1e18
dataStandardDeviations <- data.frame(xDays, yStandardDeviations)

yCounts <- transfersByDate$transferCount
dataCounts <- data.frame(xDays, yCounts)

yCumulativeSums <- transfersByDate$valueCumulativeSum/1e18
dataCumulativeSums <- data.frame(xDays, yCumulativeSums)

yFloors <- transfersByWeek$floor/1e18
yCeilings <- transfersByWeek$ceiling/1e18
dataExtrema <- data.frame(xWeeks, yFloors, yCeilings)

yUniqueOwners <- uniqueOwnerCounts$uniqueOwnerCount
dataUniqueOwners <- data.frame(xDays, yUniqueOwners)

xTransferDurations <- tokenTransferDurations$timeStamp
yTransferDurations <- tokenTransferDurations$tokenTransferDuration
dataTransferDurations <- data.frame(xTransferDurations, yTransferDurations)

xTopTokens <- head(arrange(tokens, -tokenValue), 5)$tokenID
yTopTokens <- head(arrange(tokens, -tokenValue), 5)$tokenValue/1e18
dataTopTokens <- data.frame(xTopTokens, yTopTokens)

xTopOwnersByValue <- head(arrange(owners, -sum), 5)$address
yTopOwnersByValue <- head(arrange(owners, -sum), 5)$sum/1e18
dataTopOwnersByValue <- data.frame(xTopOwnersByValue, yTopOwnersByValue)

xTopOwnersByCount <- head(arrange(owners, -count), 5)$address
yTopOwnersByCount <- head(arrange(owners, -count), 5)$count
dataTopOwnersByCount <- data.frame(xTopOwnersByCount, yTopOwnersByCount)

yGasMeans <- transfersByDate$gasMean/1e9
dataGasMeans <- data.frame(xDays, yGasMeans)


server <- function(input, output, session) {

    output$transferMean <- renderPlot({
        ggplot(
            dataMeans,
            aes(x=xDays, y=yMeans)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Value (ETH)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        theme(text=element_text(size=16))
    })

    output$transferExtrema <- renderPlot({
        ggplot(dataExtrema) +
        geom_line(aes(x=xWeeks, y=yFloors), size=1) +
        geom_line(aes(x=xWeeks, y=yCeilings), size=1) +
        labs(x="Time", y="Value (ETH) (logarithmic)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        scale_y_continuous(trans='log10') +
        theme(text=element_text(size=16))
    })

    output$transferStandardDeviations <- renderPlot({
        ggplot(
            dataStandardDeviations,
            aes(x=xDays, y=yStandardDeviations)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Standard deviation (ETH)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        theme(text=element_text(size=16))
    })

    output$transferCumulativeSums <- renderPlot({
        ggplot(
            dataCumulativeSums,
            aes(x=xDays, y=yCumulativeSums)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Cumulative value (ETH)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        theme(text=element_text(size=16))
    })

    output$transferCount <- renderPlot({
        ggplot(
            dataCounts,
            aes(x=xDays, y=yCounts)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Transfer count (logarithmic)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        scale_y_continuous(trans='log10') +
        theme(text=element_text(size=16))
    })

    output$ownerCount <- renderPlot({
        ggplot(
            dataUniqueOwners,
            aes(x=xDays, y=yUniqueOwners)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Owner count") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        theme(text=element_text(size=16))
    })

    output$topTokens <- renderPlot({
        ggplot(
            dataTopTokens,
            aes(x=reorder(as.character(xTopTokens), -yTopTokens), y=yTopTokens)
        ) +
        geom_bar(stat="identity") +
        labs(x="Token ID", y="Token value (ETH)") +
        theme(text=element_text(size=16))
    })

    output$topOwnersByValue <- renderPlot({
        ggplot(
            dataTopOwnersByValue,
            aes(x=reorder(xTopOwnersByValue, -yTopOwnersByValue), y=yTopOwnersByValue)
        ) +
        geom_bar(stat="identity") +
        labs(x="Owner address (first 8 characters)", y="Token value (ETH)") +
        theme(text=element_text(size=16))
    })

    output$topOwnersByCount <- renderPlot({
        ggplot(
            dataTopOwnersByCount,
            aes(x=reorder(xTopOwnersByCount, -yTopOwnersByCount), y=yTopOwnersByCount)
        ) +
        geom_bar(stat="identity") +
        labs(x="Owner address (first 8 characters)", y="Token count") +
        theme(text=element_text(size=16))
    })

    output$transferDurationMeans <- renderPlot({
        ggplot(
            dataTransferDurations,
            aes(x=xTransferDurations, y=yTransferDurations)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Duration (days)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        theme(text=element_text(size=16))
    })

    output$gasMean <- renderPlot({
        ggplot(
            dataGasMeans,
            aes(x=xDays, y=yGasMeans)
        ) +
        geom_line(size=1) +
        labs(x="Time", y="Value (Gwei)") +
        scale_x_date(date_breaks="2 months", date_labels="%b '%y") +
        theme(text=element_text(size=16))
    })
}
