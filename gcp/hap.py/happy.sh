BUCKET="<your bucket name>"
gcloud alpha genomics pipelines run \
  --pipeline-file happy.yaml \
  --inputs TRUTH=gs://sentieon-dnascope-model/truth/HG002_GRCh37_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-22_v.3.3.2_highconf_triophased.vcf.gz\
  --inputs QUERY=gs://$BUCKET/output/output-ds-ml.vcf.gz\
  --inputs REF=gs://sentieon-test/pipeline_test/reference/hs37d5.* \
  --inputs TRUTHBED=gs://sentieon-dnascope-model/truth/HG002_GRCh37_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-22_v.3.3.2_highconf_noinconsistent.bed \
  --inputs OUTPREFIX=happy_eval\
  --outputs outputPath=gs://$BUCKET/happy_eval/ \
  --logging gs://$BUCKET/happy_eval/logging \
  --cpus 32
