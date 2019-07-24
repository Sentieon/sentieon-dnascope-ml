BUCKET="<your google storage bucket>"
gcloud alpha genomics pipelines run \
  --pipeline-file dnascope_gcp.yaml \
  --inputs SENTIEON_VERSION=201808.07 \
  --inputs FQ1=gs://sentieon-dnascope-model/data/HG002-NA24385-50x_1.fastq.gz\
  --inputs FQ2=gs://sentieon-dnascope-model/data/HG002-NA24385-50x_2.fastq.gz\
  --inputs REF=gs://sentieon-test/pipeline_test/reference/hs37d5.* \
  --inputs DBSNP=gs://sentieon-test/pipeline_test/reference/dbsnp_138.b37.vcf.* \
  --inputs ML_MODEL=gs://sentieon-dnascope-model/models/SentieonModelBeta0.4a.model \
  --outputs outputPath=gs://$BUCKET/output/ \
  --logging gs://$BUCKET/output/logging \
  --disk-size datadisk:600 \
  --cpus 64 \
  --memory 56
