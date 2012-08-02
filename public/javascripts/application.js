// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
    $("#class_form").validationEngine();
    
 //   $("#question_filter").submit(function(){
	//alert('hi');
//	$.get(this.action, $(this).serialize(), null, "script");
	return false;
    //});
    
  });

            function checkHELLO(field, rules, i, options){
				var s = field.val()
				var t = s.replace(/\s+/g,'')
                if (t==null || t=="") {
                    // this allows to use i18 for the error msgs
                    return options.allrules.whitespace.alertText;
                }
            }


function trimString(str)
{
while (str.charAt(0) == ' ')
str = str.substring(1);
while (str.charAt(str.length - 1) == ' ')
str = str.substring(0, str.length - 1);
return str;
} 

function forgot_password_validate(){
	if(trimString(document.getElementById('email').value)==""){alert("please enter email address");document.getElementById('email').focus();return false;}

  var emailPattern =/^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/;
  var emailmatch = document.getElementById('email').value.match(emailPattern);
   if (emailmatch == null) {
    alert("Your E-mail address is invalid");
    document.getElementById('email').select();
   return false;
  }

}

function login_form_validate(){
		if(trimString(document.getElementById('user_session_login').value)==""){alert("Enter login name");document.getElementById('user_session_login').focus();return false;}
		if(trimString(document.getElementById('user_session_password').value)==""){alert("Enter password");document.getElementById('user_session_password').focus();return false;}

}

function user_registration_validate(){
		if(trimString(document.getElementById('user_name').value)==""){alert("Enter your name");document.getElementById('user_name').focus();return false;}
		if(trimString(document.getElementById('user_login').value)==""){alert("Enter login name");document.getElementById('user_login').focus();return false;}
		if(trimString(document.getElementById('user_email').value)==""){alert("Enter email id");document.getElementById('user_email').focus();return false;}
		if(trimString(document.getElementById('user_password').value)==""){alert("Enter password");document.getElementById('user_password').focus();return false;}
		if(trimString(document.getElementById('user_password_confirmation').value)==""){alert("Enter confirmation password");document.getElementById('user_password_confirmation').focus();return false;}
   
     var emailPattern =/^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/;
  	 var emailmatch = document.getElementById('user_email').value.match(emailPattern);
   		if (emailmatch == null) {
    	 alert("Your E-mail address is invalid");
    	document.getElementById('user_email').select();
   		return false;
  		}
   
   pass=trimString(document.getElementById('user_password').value);
   repass=trimString(document.getElementById('user_password_confirmation').value);
	if (pass!=repass)
	{alert("Password dosen't match confirmation")
	document.getElementById('user_password_confirmation').select();
	return false;}
}

function temporary_examinee_validate(){
		if(trimString(document.getElementById('count').value)==""){alert("Enter Number > 0");document.getElementById('count').focus();return false;}
		var countmatch = document.getElementById('count').value
	   	if (countmatch == "0") {
    	 alert("Invalid number. Number should be > 0");
    	 document.getElementById('count').select();
   		return false;
  	}
	
}

function examination_validate(){
		if(trimString(document.getElementById('exam').value)==""){alert("Please enter exam name");document.getElementById('exam').focus();return false;}
}

	

