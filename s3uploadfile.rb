require File.expand_path(File.dirname(__FILE__) + '/proj_config')

(bucket_name, file_name) = ARGV
unless bucket_name
  puts "Usage: s3uploadfile.rb <BUCKET_NAME> <FILE_NAME>"
  exit 1
end

# get an instance of the S3 interface using the default configuration
s3 = AWS::S3.new

#init bucket object
bucket = s3.buckets[bucket_name]

#check if file exists
if !File.exist?(file_name)
	puts "File '#{file_name}' does not exist. Please correct file path."
else
	if bucket.exists?
		# upload a file
		basename = File.basename(file_name)
		o = bucket.objects[basename]
		o.write(:file => file_name)

		puts "Uploaded #{file_name} to:"
		puts o.public_url

		#generate a presigned URL
		puts "\nURL to download the file:"
		puts o.url_for(:read)
	else
		puts "Bucket '#{bucket_name}' does not exist. Cannot upload file."
	end
end

