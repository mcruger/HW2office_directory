#load configs: proj_config.rb looks for config.yml
require File.expand_path(File.dirname(__FILE__) + '/proj_config')

# get an instance of the S3 interface using the default configuration
@s3 = AWS::S3.new # I know this is kind of hacky... would rather do this than manage individual files or write a class for this

#create a bucket if it doesn't exist
#create bucket if it does exist
def init_bucket(bucket_name)
	bucket = @s3.buckets[bucket_name]
	if bucket.exists?
		puts "Bucket '#{bucket_name}' already exists. Adding to this bucket."
	else
		# create a bucket
		b = @s3.buckets.create(bucket_name)
		puts "Bucket '#{bucket_name}' created."
	end
	puts " " #blank line for readibility
end

#add a file to a bucket
#file must exist and bucket must exist
def add_file_to_bucket(bucket_name, file_name)
	#init bucket object
	bucket = @s3.buckets[bucket_name]

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
	puts " " #blank line for readibility
end	

#gets a file from an existing bucket
def get_file_from_bucket(bucket_name, file_name)
	#init bucket and file object
	bucket = @s3.buckets[bucket_name]
	obj = bucket.objects[file_name]

	#check if file exists
	if !obj.exists?
		puts "File '#{file_name}' does not exist in bucket #{bucket_name}."
	else
		if bucket.exists?
			#download
			File.open(file_name, 'wb') do |file|
					obj.read do |chunk|
	                file.write(chunk)
	        end
	end
		else
			puts "Bucket '#{bucket_name}' does not exist."
		end
	end
end