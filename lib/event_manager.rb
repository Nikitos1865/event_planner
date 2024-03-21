require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'



contents = CSV.open('event_attendees.csv', 
    headers: true, 
    header_converters: :symbol
    )

def zipcode_format(zipcode)
    zipcode = zipcode.to_s.rjust(5, '0')[0..4]
end

template_letter = File.read('form_letter.erb')

erb_template = ERB.new template_letter

def rep_by_zip(zipcode)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    begin
        legislators = civic_info.representative_info_by_address(
        address: zipcode,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
      ).officials

    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end 

def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') if !Dir.exist?('output')
    filename = "output/thanks_#{id}.html"
    File.open(filename, 'w') do |file|
        file.puts form_letter
    end 
end 

def clean_phone(phone)
    phone = phone.gsub(/\W/,'').gsub(" ", '')
    if phone.length == 10
        phone
    elsif phone.length == 11 && phone[0] == '1'
        phone = phone[1..10]
    else
        'Invalid Phone Number'
    end  
end 

def get_time(reg_date)
    reg_date = reg_date.insert(6,'20')
    t = DateTime.strptime(reg_date, '%m/%d/%Y %H:%M')
    puts t.strftime('%A')
    puts t.hour()
    
end 



contents.each do |line|
    id = line[0]
    name = line[:first_name]
    phone = clean_phone(line[:homephone])
    zipcode = zipcode_format(line[:zipcode])
    legislators = rep_by_zip(zipcode)
    time = get_time(line[:regdate])

    puts time
    
    personal_letter = erb_template.result(binding)

    #save_thank_you_letter(id, personal_letter)

    puts phone

    

end