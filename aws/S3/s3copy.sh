aws s3 cp test.txt s3://yourbucketname/ --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers

# The following script shall copy your "test.txt" to the AWS bucket named "yourbucket" with the public access
# Substitute your own values to make it work (also you need to have aws cli installed and you must have an access to the S3 bucket)
