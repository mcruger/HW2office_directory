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
		b = @s3.buckets.create(bucket_name, :acl => :public_read)
		#b.configure_website do |cfg|
		 # cfg.index_document_suffix = 'index.html'
		#end
		puts "Bucket '#{bucket_name}' created."
	end
	#puts " " #blank line for readibility
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
			#o.acl = "public_read"
			o.write(:file => file_name, :acl => :public_read)

			puts "Uploaded #{file_name} to:"
			puts o.public_url

			#generate a presigned URL
		#	puts "\nURL to download the file:"
		#	puts o.url_for(:read)
		else
			puts "Bucket '#{bucket_name}' does not exist. Cannot upload file."
		end
	end
	#puts " " #blank line for readibility
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

#reads in the office dir csv file and returns hash with file contents
def read_in_csv(file_name)

#hash to hold employee data
	employeeHash = {}

	#read in .csv file 
	File.open(file_name, "r") do |f|
	  f.each_line do |line|
	  	if !line.empty? and !line.nil? 
		  	#employee, city, number
		    line = line.chomp.split(",")
		    
		    #kinda hacky, but need to track cities w/o employees
		    #if there is only 1 element listed, it's just a city with no employees
		   	is_emp = true
		    if line.count > 1
		    	employee=line[0].strip
		    	city = line[1].strip
		    	number = line[2].strip
		    else
		    	is_emp = false
		    	city = line[0].strip 
		    end
		    		
		    if employeeHash.key?(city)
		    	#push employee info into this city
		    	employeeHash[city].push [employee, number]
		    else
		    	#create new hash key and add employee
		    	employeeHash[city]=[]
		    	#check to make sure not just a city
		    	if is_emp
		    		employeeHash[city].push [employee, number] 
		    	end
		    end
		end
	  end
	end
	return employeeHash
end

#writes csv file to store office_dir data
def write_csv(file_name, employeeHash)

	File.open(file_name, "w") do |f|
		employeeHash.each do |city, employees|
			employees.each do |employee|
				f.write(city, employee[0], employee[1])
			end
		end
	end	

end

def gen_html_push_to_bucket(employeeHash, bucket_name)

	#write index.html file w/ a link to each office location (city)
	File.open("index.html", "w") do |f|
	 	f.write("<h1>Office Directory</h1>") 
		employeeHash.keys.each do |city|
			f.write("<a href=\"#{city}.html\">#{city}</a>")
			f.write("<br />")  
		end
		#upload index file
	end
	add_file_to_bucket(bucket_name, "index.html")

	#write individual html pages for each office
	employeeHash.each do |city, employees|
		city_file = "#{city}.html"
		File.open(city_file, "w") do |f|
			f.write("<a href=\"index.html\">Back to Index of Offices</a>")
			f.write("<h1>#{city} Office</h1>")
			f.write("<table border=\"1\">")
			f.write("<tr><td>Employee</td><td>Extension</td></tr>")
			if employees.any?
				employees.each do |emp|
					f.write("<tr><td>#{emp[0]}</td><td>#{emp[1]}</td></tr>")
				end
			else
				f.write("<tr><td colspan=\"2\">No Employees</td></tr>")	
			end
			f.write("</table>")
		end
		#upload the city files
		add_file_to_bucket(bucket_name, city_file)
	end
end	