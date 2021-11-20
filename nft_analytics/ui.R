library("shiny")


width <- 8

windowTitle <- "NFT Analytics"
pageTitle <- "Bored Ape Yacht Club"

priceMovementTitle <- "Price Movement"
ownerBehaviourTitle <- "Owner Behaviour"
tokenDecentralisationTitle <- "Token Decentralisation"
collectionGrowthTitle <- "Collection Growth"
externalImpactTitle <- "External Impact"

transferMeanTitle <- "Mean token value over time"
transferExtremaTitle <- "Floor and ceiling token value over time"
transferStandardDeviationsTitle <- "Token value standard deviation over time"
transferCountTitle <- "Number of token transfers over time"
transferCumulativeSumsTitle <- "Cumulative token transfer value over time"
ownerCountTitle <- "Number of unique owners over time"
transferDurationMeansTitle <- "Mean duration between token buy and sell events"
topTokensTitle <- "Top tokens by value"
topOwnersByValueTitle <- "Top owners by owned token value"
topOwnersByCountTitle <- "Top owners by count of owned tokens"
gasMeanTitle <- "Gas used from transfers over time"

# plotCaption <- ""

ui <- fluidPage(
    fluidRow(
        align='center',
        column(width=(12-width)/2),
        column(
            align='left',
            width=width,
            titlePanel(
                h2(pageTitle),
                windowTitle=windowTitle
            ),
            hr(style="border-top: 1px solid #000000;"),
            h3(priceMovementTitle),
            h4(transferMeanTitle),
            plotOutput('transferMean'),
            h4(transferExtremaTitle),
            plotOutput('transferExtrema'),
            h4(transferStandardDeviationsTitle),
            plotOutput('transferStandardDeviations'),
            hr(style="border-top: 1px solid #000000;"),
            h3(ownerBehaviourTitle),
            h4(transferCountTitle),
            plotOutput('transferCount'),
            h4(ownerCountTitle),
            plotOutput('ownerCount'),
            h4(transferDurationMeansTitle),
            plotOutput('transferDurationMeans'),
            hr(style="border-top: 1px solid #000000;"),
            h3(tokenDecentralisationTitle),
            h4(topTokensTitle),
            plotOutput('topTokens'),
            h4(topOwnersByValueTitle),
            plotOutput('topOwnersByValue'),
            h4(topOwnersByCountTitle),
            plotOutput('topOwnersByCount'),
            hr(style="border-top: 1px solid #000000;"),
            h3(collectionGrowthTitle),
            h4(transferCumulativeSumsTitle),
            plotOutput('transferCumulativeSums'),
            hr(style="border-top: 1px solid #000000;"),
            h3(externalImpactTitle),
            h4(gasMeanTitle),
            plotOutput('gasMean'),
            # p(plotCaption)
        ),
        column(width=2),
    )
)
