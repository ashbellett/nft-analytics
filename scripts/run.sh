mkdir -p ./nft_analytics/data/results
cd ./nft_analytics
Rscript ./ingest.R
Rscript ./analytics.R
Rscript ./app.R
