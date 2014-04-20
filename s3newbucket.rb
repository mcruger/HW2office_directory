
require File.expand_path(File.dirname(__FILE__) + '/proj_config')

bucket_name = ARGV[0]
unless bucket_name
  puts "Usage: s3newbucket.rb <BUCKET_NAME>"
  exit 1
end

# get an instance of the S3 interface using the default configuration
s3 = AWS::S3.new

#check if a bucket exists
bucket = s3.buckets[bucket_name]

if bucket.exists?
	puts "Bucket '#{bucket_name}' already exists. Please enter a unique bucket name."
else
	# create a bucket
	b = s3.buckets.create(bucket_name)
	puts "Bucket '#{bucket_name}' created."
end


