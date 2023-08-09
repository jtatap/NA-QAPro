/* Description : This class is for Right to Rectify and Do Not Sell/Share Customer Response*/

@RestResource(urlMapping='/public/v1/r2rProcesss/*')
global without sharing class R2RProcessResponseAPI {
    @HttpGet
    global static void restGet() {
        RestRequest req = RestContext.request;
        System.debug('The request params are ' + req.params);
        Account acc= new Account();
        String respMessage = 'Your response was not successfully processed. Please email customer support.';
        RestResponse resp = RestContext.response;
        
        Privacy_Intervals__c pi = Privacy_Intervals__c.getValues('PrivacyIntervalSetting');
        
        DateTime dueDate = system.now() + pi.MaxAfterConfirm__c/24;
		Map<String,String> mapOfBrands = new Map<String,String>();
		Schema.DescribeFieldResult fieldResult = Case.Brand__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			mapOfBrands.put(pickListVal.getValue(),pickListVal.getLabel());
		}     
		
        Map<String,Brand_Details_Mapping__mdt> mapOfBrandMappings = new Map<String,Brand_Details_Mapping__mdt>();
        
        List<Brand_Details_Mapping__mdt> listOfBrandMappings = [Select Id,Brand_Number__c,Brand_Name__c,PDR_Link__c,Email_Template__c,Ordwide_Email__c,Brand_form_link__c from Brand_Details_Mapping__mdt];
        for(Brand_Details_Mapping__mdt eachMdt : listOfBrandMappings){
            mapOfBrandMappings.put(eachMdt.Brand_Number__c, eachMdt);
            
        }
        
        Case cs = [SELECT Id,Rectified_JSON_Data__c,ContactId,R2R_Email_UserConfirmation__c,Privacy_User_Confirmed_Date__c,Sub_Type__c,
                   Resolution_Code__c,Status,VerificationHash__c,accountId,contact.firstName, contact.lastName,contact.Email_Address_Reason_Code__c,createddate,brand__c
                   FROM Case 
                   WHERE Id=:req.params.get('in_caseid')];
        cs.Due_Date__c = dueDate;
        acc.Id = cs.AccountId;
        String htmlBody = '<a href='+ mapOfBrandMappings.get(cs.brand__c).PDR_Link__c +'> Personal Data Request Form</a>';
		Boolean expired=false;
        if((((system.now().getTime())/1000/60/60) - ((cs.createdDate.getTime())/1000/60/60) > 24)||(cs.Status == 'Resolved' && cs.Resolution_Code__c =='No Response')){
            respMessage = 'This link is expired. If you\'d like to submit a new request please fill out a new'+htmlBody+'.';
            expired=true;
        }
        else if (cs.R2R_Email_UserConfirmation__c =='Started'){
          Group rtrQueue = [Select Id, Name from group where name = 'RTR Request' limit 1];
           system.debug('rtrQueue - '+rtrQueue);
           if (req.params.get('in_response') == 'Open' && req.params.get('in_verificationCode') == cs.VerificationHash__c) {
                cs.Privacy_User_Confirmed_Date__c = System.now();
                cs.Resolution_Code__c = 'User Data Provided';
                cs.R2R_Email_UserConfirmation__c = 'Confirmed'; 
                cs.Perfect_Match_Found__c = true;
                cs.Status = 'On Hold';
                if(rtrQueue != null){
                   cs.OwnerId = rtrQueue.Id;
                }
                update cs; 
               
               Contact con = new Contact();
               con.Id = cs.ContactId;
               //added as part of GCT-772
               if(cs.Sub_Type__c == Constants.doNotSellorShare){
                   if(cs.contact.Email_Address_Reason_Code__c == 'Tealium Request: Advertise OptOut'){
                   con.Advertising_Opt_out__c = 'Y';
                   con.Advertising_Opt_out_Date__c = System.Now();
                   con.OptOutShare__c = true;
                   con.Email_Address_Reason_Code__c = 'Tealium Request: Advertise OptOut';
                   }
                   else {
                   con.Advertising_Opt_out__c = 'Y';
                   con.Advertising_Opt_out_Date__c = System.Now();
                   con.OptOutShare__c = true;
                   con.Email_Address_Reason_Code__c = 'Verification Success: Do Not Sell/Share approved';
                       
                   }
                   
               }else{
               
               con.Email_Address_Reason_Code__c = 'Verification Success : R2R update';
                    
               if(string.isNotEmpty(cs.Rectified_JSON_Data__c)){
                    system.debug('cs.Rectified_JSON_Data__c***'+cs.Rectified_JSON_Data__c); 
                     system.debug('con.SelfClaimedGender__c***'+ con.SelfClaimedGender__c); 
                   
                    Map<String,Object> rectifiedJSONDataMap = (Map<String,Object>)JSON.deserializeUntyped(cs.Rectified_JSON_Data__c);
                    if(rectifiedJSONDataMap.get('newEmail')!=null && rectifiedJSONDataMap.get('newEmail') != ''){
                        con.Email = string.valueOf(rectifiedJSONDataMap.get('newEmail'));
                        con.B2C_UserName__c = string.valueOf(rectifiedJSONDataMap.get('newEmail'));
                    }
                    if(rectifiedJSONDataMap.get('newFirstName')!=null && rectifiedJSONDataMap.get('newFirstName') != ''){
                        con.FirstName = string.valueOf(rectifiedJSONDataMap.get('newFirstName'));
                        acc.name = con.FirstName +' '+ cs.contact.lastName;
                        acc.FirstName__c = con.FirstName;
                    }
                    if(rectifiedJSONDataMap.get('newLastName')!=null && rectifiedJSONDataMap.get('newLastName') != ''){
                        con.LastName = string.valueOf(rectifiedJSONDataMap.get('newLastName'));
                        if(acc.name != null && acc.name != ''){
                            acc.name = con.FirstName + ' ' + con.LastName;
                        }else{
                            acc.name = cs.contact.firstName +' '+ con.LastName;                     
                        }
                        acc.LastName__c = con.LastName;
                    }
                    if(rectifiedJSONDataMap.get('newAddress')!=null && rectifiedJSONDataMap.get('newAddress') != ''){
                        con.MailingStreet = string.valueOf(rectifiedJSONDataMap.get('newAddress'));
                    }
                    
                    if(rectifiedJSONDataMap.get('newUnit')!=null && rectifiedJSONDataMap.get('newUnit') != ''){
                        if(con.MailingStreet != null)
                        	con.MailingStreet = con.MailingStreet + ', '+string.valueOf(rectifiedJSONDataMap.get('newUnit'));
                        else
                            con.MailingStreet = string.valueOf(rectifiedJSONDataMap.get('newUnit'));
                    }
                    
                    if(rectifiedJSONDataMap.get('newCountry')!=null && rectifiedJSONDataMap.get('newCountry') != ''){
                        con.MailingCountry = string.valueOf(rectifiedJSONDataMap.get('newCountry'));
                    }
                    if(rectifiedJSONDataMap.get('newCity')!=null && rectifiedJSONDataMap.get('newCity') != ''){
                        con.MailingCity = string.valueOf(rectifiedJSONDataMap.get('newCity'));
                    }
                    if(rectifiedJSONDataMap.get('newState')!=null && rectifiedJSONDataMap.get('newState') != ''){
                        con.MailingState = string.valueOf(rectifiedJSONDataMap.get('newState'));
                    }
                    if(rectifiedJSONDataMap.get('newZipCode')!=null && rectifiedJSONDataMap.get('newZipCode') != ''){
                        con.MailingPostalCode = string.valueOf(rectifiedJSONDataMap.get('newZipCode'));
                    }
                    if(rectifiedJSONDataMap.get('newPhone')!=null && rectifiedJSONDataMap.get('newPhone') != ''){
                        con.Phone = string.valueOf(rectifiedJSONDataMap.get('newPhone'));
                    }
                    if(rectifiedJSONDataMap.get('newGender')!=null && rectifiedJSONDataMap.get('newGender') != ''){
                       // if(string.valueOf(rectifiedJSONDataMap.get('newGender'))!='-- Select Option --'){
                       // JIRA GCT-1848, GCT-6775  
                       if(string.valueOf(rectifiedJSONDataMap.get('newGender'))!='--- Select Option ---'){
                        system.debug('rectifiedJSONDataMap.get(newGender)***'+(string.valueOf(rectifiedJSONDataMap.get('newGender'))));    
                        Map<String,String> mapOfGender = new Map<String,String>();
                            mapOfGender.put('Man','M');
                            mapOfGender.put('Woman','F');
                           //JIRA GCT-7509  
                            mapOfGender.put('Gender Diverse','GN');
                            mapOfGender.put('Prefer not to say','PNTS');
                        con.SelfClaimedGender__c = mapOfGender.get(string.valueOf(rectifiedJSONDataMap.get('newGender')));
                        }
                    } 
                     if(rectifiedJSONDataMap.get('newDate')!=null && rectifiedJSONDataMap.get('newDate') != '' && rectifiedJSONDataMap.get('newDate')!='--- Select Option ---'
                       && rectifiedJSONDataMap.get('newMonth')!=null && rectifiedJSONDataMap.get('newMonth') != '' && rectifiedJSONDataMap.get('newMonth')!='--- Select Option ---'){
                           con.birthdate = Date.newInstance(1900, integer.valueOf(rectifiedJSONDataMap.get('newMonth')), integer.valueOf(rectifiedJSONDataMap.get('newDate')));
                       }
                }
               }
                req.params.put('in_caseid', cs.ContactId);
                req.params.put('updateContact', JSON.serialize(con));
                Flow.Interview.Call_Email_service_when_case_updated flow1 = new Flow.Interview.Call_Email_service_when_case_updated(req.params);
            	flow1.start();
                update acc;
               	System.debug('+++++ createChildDataOwnerCases check');
                System.debug('email address reason code ' + con.Email_Address_Reason_Code__c);
                if(con.Email_Address_Reason_Code__c == 'Verification Success : R2R update' ||con.Email_Address_Reason_Code__c == 'Verification Success: Do Not Sell/Share approved' || con.Email_Address_Reason_Code__c == 'Tealium Request: Advertise OptOut'){//added as part of GCT-772
                System.debug('+++++ inside createChildDataOwnerCases check' + con.Email_Address_Reason_Code__c);
                    ChildPrivacyCaseActionsHandler.createChildDataOwnerCases(cs.Id);
                }
                respMessage = 'Your response was successfully processed. Click here to close the window';
            }
            else if (req.params.get('in_response') == 'Resolved' && req.params.get('in_verificationCode') == cs.VerificationHash__c) {
                system.debug('inside resolved condition>>>>>');
                cs.Privacy_User_Confirmed_Date__c = System.now();
                cs.Resolution_Code__c = 'Rejected Request';
                cs.R2R_Email_UserConfirmation__c = 'Rejected'; 
                cs.Status = 'Resolved';
                if(rtrQueue != null){
                   cs.OwnerId = rtrQueue.Id;
                }
                update cs;
                /*Flow.Interview.Call_Email_service_when_case_updated flow1 = new Flow.Interview.Call_Email_service_when_case_updated(req.params);
            	flow1.start();*/
                
                Contact con = new Contact();
                con.Id = cs.ContactId;
                if(cs.Sub_Type__c == Constants.rectifyRequestSubType){
                    con.Email_Address_Reason_Code__c = 'Verification Declined: No personal data update';
                }else if(cs.Sub_Type__c == Constants.doNotSellorShare){//added as part of GCT-772
                    con.Email_Address_Reason_Code__c = 'Verification Declined: No Advertising Opt Out';
                }
                system.debug('con--'+cs.ContactId);
                req.params.put('in_caseid', cs.ContactId);
                update con;
                update acc;
                
                req.params.put('updateContact', JSON.serialize(con));
                Flow.Interview.Call_Email_service_when_case_updated flow1 = new Flow.Interview.Call_Email_service_when_case_updated(req.params);
            	flow1.start();
                
                respMessage = 'Thank you for your response. Please note that no changes have been made to your account.';
                
            }
        }else{
            respMessage ='We are sorry, but a response was previously recorded in our system.';
        }
        String response;
        if(expired){
            response =  '<html><head><title>PVH Privacy Request Processing</title><script type="text/javascript">' +
            '    function closeCurrentTab(){ ' +
            '		var conf=confirm("Are you sure, you want to close this tab?"); ' +
            '		if(conf==true){ ' +
            '			close(); ' +
            '		} ' +
            '	} ' +
            '</script> ' +
            '</head><body style="text-align: center;">' +
            '<p>' + respMessage +  '</body></html>' ;
        }else{
            response =  '<html><head><title>PVH Privacy Request Processing</title><script type="text/javascript">' +
            '    function closeCurrentTab(){ ' +
            '		var conf=confirm("Are you sure, you want to close this tab?"); ' +
            '		if(conf==true){ ' +
            '			close(); ' +
            '		} ' +
            '	} ' +
            '</script> ' +
            '</head><body style="text-align: center;">' +
            '<p><input type="button" value="' + respMessage + '" onclick="window.close()"' + '</body></html>' ;
        }
        resp.responseBody = Blob.valueOf(response);
        resp.headers.put('Content-Type', 'text/html; charset=utf-8');
    }   
}