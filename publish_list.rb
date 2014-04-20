#office directory

#accepts name of s3 bucket and csv file
#create bucket if it doesn't exist
#parse file to create two types of objects
#i. HTML page for each city, which displays the city name, a table of the employees in that city, 
#and a link back to the index page. 
#ii. an HTML index page which lists links to the city pages 

#place objects AND csv file in bucket
# print url to access page

#set configs
#require File.expand_path(File.dirname(__FILE__) + '/proj_config')
require "./office_directory_utility.rb"

#check intput
(bucket_name, file_name) = ARGV
unless bucket_name && file_name
  puts "Usage: publish_list.rb <BUCKET_NAME> <FILE_NAME>"
  exit 1
end

# get an instance of the S3 interface using the default configuration
#s3 = AWS::S3.new

#check if a bucket exists, create it if it doesn't exist
init_bucket(bucket_name)

#read in csv file
employeeHash = read_in_csv(file_name)

#gen html files and push to bucket
gen_html_push_to_bucket(employeeHash, bucket_name)

#add csv file to bucket
add_file_to_bucket(bucket_name, file_name)