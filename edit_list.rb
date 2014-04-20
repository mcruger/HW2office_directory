#1. The program takes one parameter: the bucket name for the office directory 
#2. It displays the cities as a numbered list and accepts appropriate numbers as input 
#3. It displays the employees in the selected city in a numbered list and accepts appropriate numbers as input.
#4. It requests the name, office location and phone extension for the selected employee.
#5. It updates the csv file and the appropriate city HTML page. 

#set configs
#require File.expand_path(File.dirname(__FILE__) + '/proj_config')
require "./s3utility"
require "./office_directory_utility.rb"

#check intput
bucket_name = ARGV[0]
unless bucket_name
  puts "Usage: edit_list.rb <BUCKET_NAME>"
  exit 1
end

csv_file = "office_dir.csv"

#get .csv file from bucket
get_file_from_bucket(bucket_name, csv_file)

#read in csv file
employeeHash = read_in_csv("input.csv") #hardcoded for now, needs to find a csv file

using_prog = true

while using_prog == true do
	#output list of cities to user
	city_count = 1
	new_emp = false
	puts ""
	puts "Enter the number for the city you want to edit, 'save' to save your changes, or 'quit' to exit."
	puts ""

	puts "0. Add New Employee"
	employeeHash.keys.each do |city|
		puts "#{city_count}. #{city}"
		city_count += 1
	end
	puts ""
	#capture user input
	mod_city = STDIN.gets.chomp

	if mod_city == "save"
		#generate html pages and push to bucket
		gen_html_push_to_bucket(employeeHash, bucket_name)
		puts "Changes saved and office directory updated!"
		puts ""
		next
	elsif mod_city == "quit"
		puts "Any unsaved changes will be lost. Are you sure you want to quit?"
		puts "[Y/y] to quit."
		mod_in = STDIN.gets.chomp
		if mod_in.downcase == "y"
			puts "Goodbye!"
			using_prog = false
			break
		else
			next
		end
	elsif mod_city.to_i < 0 or mod_city.to_i > employeeHash.keys.count or mod_city.to_i.to_s != mod_city
		puts "Invalid entry!"
		puts ""
		next
	else			

		if mod_city.to_i == 0
			new_emp = true
		end

		if new_emp == false
			#show employees for selected city. Note that I'm subtracting 1 from mod_city b/c it isn't 0 based.
			no_emps = false
			emp_count = 1
			if employeeHash.values[mod_city.to_i - 1].empty?
				no_emps = true
				puts "No Employees at this office!"
				puts "0. Back to Main Menu"
				puts "1. Enter New Employee"
			else
				puts "Enter the number for the employee you want to edit"
				puts "0. Back to Main Menu"
				employeeHash.values[mod_city.to_i - 1].each do |employee|
					puts "#{emp_count}. #{employee}" 
					emp_count += 1
				end
			end

			#capture user input
			mod_emp = STDIN.gets.chomp

			#kick back to main menu if 0 is entered
			if mod_emp == "0"
				next
			end	

			#check for new employee option on empty offices
			if no_emps and mod_emp == "1"
				new_emp = true	
			end
		end

		if new_emp
			#get updated employee details
			puts "You are adding a new employee.."
		else
			emp_city = employeeHash.keys[mod_city.to_i - 1]
			emp_name = employeeHash.values[mod_city.to_i - 1][mod_emp.to_i - 1][0]
			emp_ext = employeeHash.values[mod_city.to_i - 1][mod_emp.to_i - 1][1]
			 
			#get updated employee details
			puts "You are editing #{emp_city}, #{emp_name}, #{emp_ext}"
		end	
		
		puts "Please enter Office employee is located at..."
		mod_emp_city = STDIN.gets.chomp
		puts "Please enter employee Name..."
		mod_emp_name = STDIN.gets.chomp
		puts "Enter employee Extension..."
		mod_emp_extension = STDIN.gets.chomp

		#city move, need to move employee to a new city

		#check to see if city exists. create new one if it doesn't
		if !employeeHash.key?(mod_emp_city)
			employeeHash[mod_emp_city]=[]
		end
		puts mod_city
		#insert new record and remove one
		employeeHash[mod_emp_city].push [mod_emp_name, mod_emp_extension]
		
		if new_emp == false
			employeeHash.values[mod_city.to_i - 1].delete_at(mod_emp.to_i - 1)
		end

		puts ""
		puts "Record updated, remember to save your changes."
		puts ""
	end
end
