# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first) 
 
User.create( :name => 'admin', :login => 'admin', :email => 'nirmal_success@yahoo.co.in', :password => 'admin',:role_id=>1,:confirmed=>true,:is_approved=>1,:active=>true)

Setting.create( :allow_examinee_registration => true, :confirm_exam=> true, :datetime_format=>'%m/%d/%Y', :locale=>'en' )

 ["admin", "examiner", "questionsetter","examinee"].each do |r|  
   Role.find_or_create_by_name r  
 end 

# ["t1", "t2", "t3", "t4", "t5", "t6","t7"].each do |r|  
#   Email.find_or_create_by_section_id r  
# end
 
 ["school", "university/college", "organization","training_center"].each do |r|  
   Organization.find_or_create_by_title r  
 end 
 
 
   ["course,1,1","section,1,2","course,2,1","academic_year,2,2","department,2,3","semester,2,4","department,3,1","domain,4,1"] .each do |category|  
     a,b,c = category.chomp.split(",")  
     CategoryType.create!(:title => a, :organization_id => b, :sort_order=>c)  
   end  

 ["MultipleChoice", "MultipleSelection", "Fill in the blanks","Yes or No", "True or False", "Drag and Drop","Likert","Matrix","Image based","Hierarchical ordering","Matching","Descriptive"].each do |r|  
   QuestionType.find_or_create_by_name r  
 end


  ["Dear $^_username_^$,<br><br>
Now your are registered user of VirtualX! <br>
Please wait till you receive your account activated mail to login to the system.<br><br>
Thanks*t1*User Name <=> $^_username_^$*Liebe $^_username_^$,<br><br>
Jetzt ist Ihr sind registrierter Benutzer von VirtualX! <br>
Bitte warten Sie, bis Sie Ihr Konto aktiviert mail an das System anmelden erhalten.<br><br>
Dank",



  "Dear $^_username_^$, <br><br>
 Your account has been created. You can login with the following credentials after you have activated your account by clicking the url below.<br><br> 
 ------------------------ <br>
 User Id: $^_userlogin_^$ <br>
 ------------------------ <br><br>
 Please click this link to activate your account*t2*
 User Name <=> $^_username_^$<br>  User LoginId <=> $^_userlogin_^$*
 Liebe $^_username_^$, <br><br>
Ihr Konto wurde erstellt. Sie konnen mit den folgenden Anmeldeinformationen anmelden, nachdem Sie Ihr Konto, indem Sie die unten angegebene URL aktiviert haben.<br><br> 
 ------------------------ <br>
 User Id: $^_userlogin_^$ <br>
 ------------------------ <br><br>
 Bitte klicken Sie diesen Link, um Ihr Konto zu aktivieren",
 
 
 
   "Dear $^_username_^$,<br><br>
Your account has been rejected. <br><br>
Thanks*t3*User Name <=> $^_username_^$*Liebe $^_username_^$,<br><br>
Ihr Konto wurde abgelehnt. <br><br>
Dank",



   "Dear $^_username_^$,<br><br>
Your account has been created with VirtualX.<br><br>
You can login to the system with following credentials. <br><br>
------------------------ <br>
User Id: $^_userlogin_^$ <br>
------------------------ <br><br>
Please verify your email-id and set password by clicking the link below*t4*
User Name <=> $^_username_^$<br>  User Login <=> $^_userlogin_^$*Liebe $^_username_^$,<br><br>
Ihr Konto wurde mit VirtualX geschaffen.<br><br>
Sie konnen das System mit folgenden Zugangsdaten einloggen. <br><br>
------------------------ <br>
User Id: $^_userlogin_^$ <br>
------------------------ <br><br>
Bitte uberprufen Sie Ihre E-Mail-ID und set password, indem Sie den untenstehenden Link.<br>",
   
   
"Dear $^_username_^$,<br><br>
To Reset your password click on the link below*t5*User Name <=> $^_username_^$*Liebe $^_username_^$,<br><br>
Ihr Passwort zurucksetzen auf untenstehenden Link klicken",
   
   
"Dear User,<br><br>
You have an attachment with list of Temporary Examinees.<br><br>
Thanks*t6* *Sehr geehrter Nutzer,<br><br>
Sie haben einen Anhang mit einer Liste der Temporary Prufling.<br><br>
Dank",


 
 "Dear $^_username_^$,<br><br>
 Your exam schedule details are given below.<br><br> 
 ------------------------ <br>
 Exam name: $^_examname_^$ <br>
 Exam code:  $^_examcode_^$ <br>
 Exam date:  $^_examdate_^$ <br>
 Exam time:  $^_examtime_^$ <br>
 Exam duration: $^_examduration_^$ <br>
 ------------------------ <br><br>
Thanks*t8*User Name <=> $^_username_^$*Liebe $^_username_^$,<br><br>
Ihre Prufung Zeitplan Details sind unten angegeben.<br><br> 
 ------------------------ <br>
 Prufung Name: $^_examname_^$ <br>
 Prufung Code:  $^_examcode_^$ <br>
 Prufung Datum:  $^_examdate_^$ <br>
 Prufung Zeit:  $^_examtime_^$ <br>
 Prufung Dauer: $^_examduration_^$ <br>
 ------------------------ <br><br>Dank"] .each do |email|  
     a,b,c,d = email.chomp.split("*")  
     Email.create!(:content => a, :section_id => b, :help_content=>c, :content_de=>d)  
   end


   ["VirtualX is an online examination management system which provides a basis for effective fulfillment of conducting online exam in an efficient manner. This system efficiently evaluates the candidates thoroughly through the fully automated system that not only save the time but also gives fast result. The system supports report generation and feedback management.*1",
   "VirtualX ist eine Online-Prufung-Management-System, die eine Grundlage fur eine effektive Erfullung der Durchfuhrung von Online-Prufung auf effiziente Weise zur Verfugung stellt. Dieses System effizient beurteilt die Kandidaten grundlich durch das voll automatisiertes System, das spart nicht nur Zeit, sondern gibt auch schnelle Ergebnis. Das System unterstutzt Berichterstellung und Feedback-Management.*2"] .each do |about|  
     a,b = about.chomp.split("*")  
     Aboutus.create!(:description => a, :locale_id => b)  
   end  
