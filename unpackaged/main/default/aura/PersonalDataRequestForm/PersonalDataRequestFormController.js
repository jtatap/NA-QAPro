({
  doInit: function(component, event, helper) {
    console.log("***inside doInit");
    var brandNames = component.get("v.brandNames");
    var appEvent = $A.get("e.c:appBrandNameEvent");
    appEvent.setParam("brandName", brandNames);
    appEvent.fire();
        try{
      if(brandNames.includes('2')){
          component.set("v.hasTH", true);
      }
            // updated for GCT-1249 - start
      var monthValues=["01","02","03","04","05","06","07","08","09","10","11","12"];
          var dateValues=[];
        
          for(var i=1;i<=31 ;i++){
              
             // if(i<13){
                 // if(i.toString().length == 1){
                      //monthValues.push("0"+i); 
                 // }else{
                  	//monthValues.push(i); 
                  //}
             // }	
             // updated for GCT-1249 - end
              if(i.toString().length == 1){
                  dateValues.push("0"+i);
              }else{
              	  dateValues.push(i);
              }
          }
           
          component.set("v.monthVals",monthValues);
          component.set("v.dateVals",dateValues);
          }catch(err) {
              console.log(err);
          }
    // get the fields API name and pass it to helper function
    var controllingFieldAPI = component.get("v.controllingFieldAPI");
    var dependingFieldAPI = component.get("v.dependingFieldAPI");
    var objDetails = component.get("v.objDetail");
    // call the helper function
    helper.fetchPicklistValues(
      component,
      objDetails,
      controllingFieldAPI,
      dependingFieldAPI
    );
  },
    // added for GCT-1249
     changeNumberOfDays: function(component, event, helper){
    var dateValues=[];
    var birthMonth = component.get("v.changedMonth");
    var oddMonths = ["04","06","09","11"];
        
       
          for(var i=1;i<=31 ;i++){
            
            if(i.toString().length == 1){
                dateValues.push("0"+i);
            }else{
                dateValues.push(i);
            }
            if(i==29 && birthMonth == "02" ){
              break;
            }
            if(i==30 && oddMonths.includes(birthMonth)){
              break;
            }
        }
            
        
        component.set("v.dateVals",dateValues);
 
 },
    changeEmail: function(component, event, helper){
       var contDetails = component.get("v.contactDetails"); 
       var emailRegex = "";
            if(!(component.get("v.changedEmail") == "")){
           if(component.get("v.changedEmail") == contDetails.Email){
               console.log("old email address") ;
               component.find("changedEmail").setCustomValidity("Email is same as old email");
    			component.find("changedEmail").reportValidity();
           }else {
              component.find("changedEmail").setCustomValidity("");
           }  
       		
    	
            }  else {
              component.find("changedEmail").setCustomValidity("Please enter the email address");
           }  
        component.find("changedEmail").reportValidity();
    },
    
     changeFirstName: function(component, event, helper){
    
       var contDetails = component.get("v.contactDetails"); 
         
           if(component.get("v.changedFirstName") == contDetails.FirstName){
               component.find("changedFirstName").setCustomValidity("First name is same as old one");
    			component.find("changedFirstName").reportValidity();
           }  else{
               component.find("changedFirstName").setCustomValidity("");
    			component.find("changedFirstName").reportValidity();
           }
    
    },
    
    changeLastName: function(component, event, helper){
    
       var contDetails = component.get("v.contactDetails"); 
           
           if(component.get("v.changedLastName") == contDetails.Email){
               component.find("changedLastName").setCustomValidity("Last name is same as old one");
    			component.find("changedLastName").reportValidity();
           }  
    
    },
    
       changeCity: function(component, event, helper){
    
       var contDetails = component.get("v.contactDetails"); 
           
           if(component.get("v.changedcity") == contDetails.MailingCity){
               component.find("changedcity").setCustomValidity("City is same as old one");
    			component.find("changedcity").reportValidity();
           }
    
    },
    
     changeCountry: function(component, event, helper){
    
       var contDetails = component.get("v.contactDetails"); 
          if(component.get("v.changedCountry") == contDetails.MailingCountry){
               component.find("changedCountry").setCustomValidity("Country is same as old one");
    			component.find("changedCountry").reportValidity();
           }  
         
     },
    
    changePostalCode: function(component, event, helper){
        
        var contDetails = component.get("v.contactDetails"); 
        
        if(component.get("v.changedZipCode") == contDetails.MailingPostalCode){
            component.find("changedZipCode").setCustomValidity("ZipCode is same as old one");
    			component.find("changedZipCode").reportValidity();
           }  
    
    },
    
   openModel: function(component, event, helper) {
       try{
       var changedText ='';
       var textdata=[];
       
			if(component.find("changedFirstName"))
            var email = component.find("changedFirstName").get("v.validity");
             if(component.find("changedLastName"))
            var fname = component.find("changedLastName").get("v.validity");  
            if(component.find("changedEmail"))
            var lname = component.find("changedEmail").get("v.validity");
           if(component.find("changedAddress"))
            var address = component.find("changedAddress").get("v.validity");
           if(component.find("changedUnit"))
            var unit = component.find("changedUnit").get("v.validity");
           if(component.find("changedcity"))
            var city = component.find("changedcity").get("v.validity");
           if(component.find("changedCountry"))
            var country = component.find("changedCountry").get("v.validity");
           if(component.find("changedState"))
            var state = component.find("changedState").get("v.validity");
           if(component.find("changedZipCode"))
            var zipcode = component.find("changedZipCode").get("v.validity");
           if(component.find("changedPhone"))
            var phone = component.find("changedPhone").get("v.validity");
           if(component.find("changedGender"))
            var gender = component.find("changedGender").get("v.validity");
           if(component.find("changedDate"))
            var bmonth = component.find("changedDate").get("v.validity");
           if(component.find("changedMonth"))
            var bday = component.find("changedMonth").get("v.validity");
           
           if((email==undefined || email.valid)
          && (fname==undefined || fname.valid) 
          && (lname==undefined || lname.valid)
          && (address==undefined || address.valid)
          && (unit==undefined || unit.valid)
          && (city==undefined || city.valid)
          && (country==undefined || country.valid) 
          && (state==undefined || state.valid) 
          && (zipcode==undefined || zipcode.valid)
          && (phone==undefined || phone.valid)
          && (gender==undefined || gender.valid) 
          && (bmonth==undefined || bmonth.valid) 
          && (bday==undefined || bday.valid)){
           component.set("v.mapData",'')
		var contDetails = component.get("v.contactDetails");     
         var mapTxt = component.get("v.mapData");
       if(component.get("v.checkEmail")){
           textdata.push("Email Address: "+component.get("v.changedEmail"));
           mapTxt.push({value:"Email Address: ", key:component.get("v.changedEmail")});
           if(component.get("v.changedEmail") != undefined)
           changedText = changedText +"\nEmail Address: "+component.get("v.changedEmail");
       }
 
       if(component.get("v.checkFirstName")){
           textdata.push("First Name: "+component.get("v.changedFirstName"));
           mapTxt.push({value:"First Name: ", key:component.get("v.changedFirstName")});
           if(component.get("v.changedFirstName") != undefined)
           changedText = changedText +"\nFirst Name: "+component.get("v.changedFirstName");
       }

           if(component.get("v.checkLastName")){
               textdata.push("Last Name: "+component.get("v.changedLastName"));
               mapTxt.push({value:"Last Name: ", key:component.get("v.changedLastName")});
               if(component.get("v.changedLastName") != undefined)
               changedText = changedText +"\nLast Name: "+component.get("v.changedLastName");
           }

           if(component.get("v.checkAddress")){
				textdata.push("Address: "+component.get("v.changedAddress"));
               mapTxt.push({value:"Address: ", key:component.get("v.changedAddress")});
               if(component.get("v.changedAddress") != undefined)
               changedText = changedText +"\nAddress: "+component.get("v.changedAddress");
               if(component.get("v.changedUnit") != undefined && component.get("v.changedUnit") != ''){
                   textdata.push("Apartment/Suite/Unit: "+component.get("v.changedUnit"));
                   mapTxt.push({value:"Apartment/Suite/Unit: ", key:component.get("v.changedUnit")});
                   if(component.get("v.changedUnit") != undefined)
                   changedText = changedText +"\nApartment/Suite/Unit: "+component.get("v.changedUnit");
               }
               textdata.push("City: "+component.get("v.changedcity"));
               mapTxt.push({value:"City: ", key:component.get("v.changedcity")});
               if(component.get("v.changedcity") != undefined)
               changedText = changedText +"\nCity: "+component.get("v.changedcity");
               if(component.get("v.changedState") != undefined){
               textdata.push("State/Province: "+component.get("v.changedState"));
               mapTxt.push({value:"State/Province: ", key:component.get("v.changedState")});
               }
               changedText = changedText +"\nState/Province: "+component.get("v.changedState");
               textdata.push("Territory: "+component.get("v.changedCountry"));
               mapTxt.push({value:"Territory: ", key:component.get("v.changedCountry")});
               if(component.get("v.changedCountry") != undefined)
               changedText = changedText +"\nTerritory: "+component.get("v.changedCountry");
               textdata.push("Zip Code: "+component.get("v.changedZipCode"));
               mapTxt.push({value:"Zip Code: ", key:component.get("v.changedZipCode")});
               if(component.get("v.changedZipCode") != undefined)
               changedText = changedText +"\nZip Code: "+component.get("v.changedZipCode");
           }
 
           if(component.get("v.checkPhone")){
               var phone = component.get("v.changedPhone");
               var input = phone.replace(/\D/g, '');
               if (input.length === 10) {
                   var areaCode = input.substring(0, 3);
                   var middle = input.substring(3, 6);
                   var last = input.substring(6, 10);
                   var phoneFormat = areaCode + ' ' + middle + ' ' + last;
               }
               textdata.push('Phone: '+phoneFormat);
               mapTxt.push({value:"Phone: ", key:phoneFormat});
               if(component.get("v.changedPhone") != undefined)
               changedText = changedText + "\nPhone: "+component.get("v.changedPhone");
           }
              
           if(component.get("v.checkGender")){
                textdata.push('Gender: '+component.get("v.changedGender"));
                mapTxt.push({value:"Gender: ", key:component.get("v.changedGender")});
               if(component.get("v.changedGender") != undefined)
               changedText = changedText + "\nGender: "+component.get("v.changedGender");

           }

           if(component.get("v.checkBirthday")){
	   			 textdata.push('Birthday (Month/Day): '+component.get("v.changedMonth")+'/'+component.get("v.changedDate"));
                 mapTxt.push({value:"Birthday (Month/Day): ", key:component.get("v.changedMonth")+'/'+component.get("v.changedDate")});
               if(component.get("v.changedMonth") != undefined && component.get("v.changedDate") != undefined )
               changedText = changedText + "\nBirthday (Month/Day): "+component.get("v.changedMonth")+'/'+component.get("v.changedDate");
           } 
               if(!(component.get("v.checkEmail") ||  component.get("v.checkFirstName") ||  component.get("v.checkLastName") ||  component.get("v.checkAddress")
                    || component.get("v.checkPhone")
                    ||  component.get("v.checkGender")||  component.get("v.checkBirthday"))){
                   helper.showToast(
                       component,
                       event,
                       helper,
                       "error",
                       "Error: ",
                       "Please enter data to submit"
                   );
                   
               }else if(component.get("v.associatedEmail") == undefined || component.get("v.associatedEmail") == ''){
                   helper.showToast(
                       component,
                       event,
                       helper,
                       "error",
                       "Error: ",
                       "Please enter associated email"
                   );
               }
               else{
                   component.set("v.changedData", changedText);
                   component.set("v.textData", textdata);
                   component.set("v.mapData", mapTxt);
                   // Set isModalOpen attribute to true
                   component.set("v.isModalOpen", true);
               }
       }
           else{
               helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please review error on this page"
      );
           }
       }catch(err){
           console.log(err);
       }
       
   },
    
    createCaseForDoNotSell :function(component, event, helper) {
  
            helper.handleDonotSellShare(component, event);
    },
  
   closeModel: function(component, event, helper) {
       component.set("v.changedData", "");
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.isModalOpen", false);
   },

  onControllerFieldChange: function(component, event, helper) {
    var getCountry = component.find("country").get("v.value");

    if (getCountry == "United States of America (USA)") {
      component.set("v.isStateVisible", true);
    } else {
      component.set("v.isStateVisible", false);
      component.set("v.newCase.State_of_Residence__c", null);
    }

    var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
    var depnedentFieldMap = component.get("v.depnedentFieldMap");

    if (controllerValueKey != "--- None ---") {
      var ListOfDependentFields = depnedentFieldMap[controllerValueKey];

      if (ListOfDependentFields.length > 0) {
        component.set("v.bDisabledDependentFld", false);
        helper.fetchDepValues(component, ListOfDependentFields);
      } else {
        component.set("v.bDisabledDependentFld", true);
        component.set("v.listDependingValues", ["--- None ---"]);
      }
    } else {
      component.set("v.listDependingValues", ["--- None ---"]);
      component.set("v.bDisabledDependentFld", true);
    }
  },

  // this function automatic call by aura:waiting event
  showSpinner: function(component, event, helper) {
    // make Spinner attribute true for display loading spinner
    component.set("v.Spinner", true);
  },

  // this function automatic call by aura:doneWaiting event
  hideSpinner: function(component, event, helper) {
    // make Spinner attribute to false for hide loading spinner
    component.set("v.Spinner", false);
  },
  
  //Added by Sekhar
  changeRequestType: function(component, event, helper) {
      if(component.get("v.newCase.Type") == 'Rectify My Data'){
          
          	    component.set("v.checkEmail", false);
              	component.set("v.checkFirstName", false);
              	component.set("v.checkLastName", false);
              	component.set("v.checkAddress", false);
              	component.set("v.checkPhone", false);
              	component.set("v.checkGender", false);
              	component.set("v.checkBirthday", false);
          
          		component.set("v.changedEmail", '');
          component.set("v.changedFirstName", '');
          component.set("v.changedLastName", '');
          component.set("v.changedAddress", '');
          component.set("v.changedUnit", '');
          component.set("v.changedcity", '');
          component.set("v.changedCountry", '');
          component.set("v.changedState", '');
          component.set("v.changedZipCode", '');
          component.set("v.changedPhone", '');
          component.set("v.changedGender", '--- Select Option ---');
          component.set("v.changedDate", '--- Select Option ---');
          component.set("v.changedMonth", '--- Select Option ---');
          
		 component.set("v.otherRequests", false);
          component.set("v.showRectifyData", true);
          component.set("v.doNotSellShare", false);
          
      }else if(component.get("v.newCase.Type") == 'Unsubscribe' || component.get("v.newCase.Type") == 'Delete My Data' || component.get("v.newCase.Type") == 'Access My Data'){
          component.set("v.otherRequests", true);
          component.set("v.showRectifyData", false);
          component.set("v.doNotSellShare", false);
          
      }else if(component.get("v.newCase.Type") == 'Advertising/Sharing Opt-Out'){
          component.set("v.otherRequests", false);
          component.set("v.showRectifyData", false);
          component.set("v.doNotSellShare", true);
      }
  },
    
  changeCheck: function(component, event, helper) {
      var auraId = event.getSource().getLocalId();
		console.log('auraId '+auraId);
        var changeCheckAttributes;
          if(auraId == 'emailCheck'){
              if(component.get("v.checkEmail"))
              	component.set("v.checkEmail", false);
              else
                component.set("v.checkEmail", true);
          }else if(auraId == 'firstNameCheck'){
              if(component.get("v.checkFirstName"))
              	component.set("v.checkFirstName", false);
              else
                component.set("v.checkFirstName", true);
          }else if(auraId == 'lastNameCheck'){
              if(component.get("v.checkLastName"))
              	component.set("v.checkLastName", false);
              else
                component.set("v.checkLastName", true);
          }else if(auraId == 'addressCheck'){
              if(component.get("v.checkAddress"))
              	component.set("v.checkAddress", false);
              else
                component.set("v.checkAddress", true);
          }else if(auraId == 'phoneCheck'){
              if(component.get("v.checkPhone"))
              	component.set("v.checkPhone", false);
              else
                component.set("v.checkPhone", true);
          }else if(auraId == 'genderCheck'){
              if(component.get("v.checkGender"))
              	component.set("v.checkGender", false);
              else
                component.set("v.checkGender", true);
          }else if(auraId == 'birthDayCheck'){
              if(component.get("v.checkBirthday"))
              	component.set("v.checkBirthday", false);
              else
                component.set("v.checkBirthday", true);
          }
          
  },
    
  checkForEmail: function(component, event, helper) {
      if(component.get("v.associatedEmail")!=undefined && component.get("v.associatedEmail")!='' && component.get("v.associatedEmail").includes('@'))  {    
      	helper.handleRectifyDataHelper(component, event, null, false);
      }else{
          component.set("v.showErr",false);
      }
  },
    
  handleRectifyData : function(component, event, helper) {
      // added for GCT-1249
     var monthMapper = new Map([
        ["01", "01"],
        ["02", "02"],
        ["03", "03"],
        ["04", "04"],
        ["05", "05"],
        ["06", "06"],
        ["07", "07"],
        ["08", "08"],
        ["09", "09"],
        ["10", "10"],
        ["11", "11"],
        ["12", "12"]
    ]);
      var phone = component.get("v.changedPhone");
      var input = phone.replace(/\D/g, '');
      if (input.length === 10) {
          var areaCode = input.substring(0, 3);
          var middle = input.substring(3, 6);
          var last = input.substring(6, 10);
          var phoneFormat = areaCode + ' ' + middle + ' ' + last;
      }
      var dataWrapper={};
      dataWrapper.newEmail = component.get("v.changedEmail");
      dataWrapper.newFirstName = component.get("v.changedFirstName");
      dataWrapper.newLastName = component.get("v.changedLastName");
      dataWrapper.newAddress = component.get("v.changedAddress");
      dataWrapper.newUnit = component.get("v.changedUnit");
      dataWrapper.newCity = component.get("v.changedcity");
      dataWrapper.newCountry = component.get("v.changedCountry");
      dataWrapper.newState = component.get("v.changedState");
      dataWrapper.newZipCode = component.get("v.changedZipCode");
      dataWrapper.newPhone = phoneFormat;
      dataWrapper.newGender = component.get("v.changedGender");
      // added for GCT-1249
      dataWrapper.newMonth = monthMapper.get(component.get("v.changedMonth"));
      dataWrapper.newDate = component.get("v.changedDate");
      
      var jsonData = JSON.stringify(dataWrapper);
      console.log('---'+jsonData);
      helper.handleRectifyDataHelper(component, event, component.get("v.changedData"), true,jsonData);
          
      
  },

  handleSendMessage: function(component, event, helper) {
    console.log("***Submit Clicked");
    component.find("firstname").setCustomValidity("");
    component.find("firstname").reportValidity();

    component.find("lastname").setCustomValidity("");
    component.find("lastname").reportValidity();

    component.find("email").setCustomValidity("");
    component.find("email").reportValidity();

    component.find("phone").setCustomValidity("");
    component.find("phone").reportValidity();

    component.find("loyaltyID").setCustomValidity("");
    component.find("loyaltyID").reportValidity();

    var typeOfRequest = component.find("typeOfRequest").get("v.value");
    var country = component.find("country").get("v.value");

    if (component.get("v.isStateVisible"))
      var state = component.find("state").get("v.value");

    var firstname = component.find("firstname").get("v.value");
    var lastname = component.find("lastname").get("v.value");
    var getEmail = component.find("email");
    var inputEmail = getEmail.get("v.value");
    var inputPhone = component.find("phone").get("v.value");
    var inputLoyaltyID = component.find("loyaltyID").get("v.value");
    console.log("***typeOfRequest = " + typeOfRequest);
    console.log("***country = " + country);

    if (component.get("v.isStateVisible")) console.log("***state = " + state);

    console.log("***firstname = " + firstname);
    console.log("***lastname = " + lastname);
    console.log("***email = " + inputEmail);
    console.log("***phone = " + inputPhone);
    console.log("***loyalty id = " + inputLoyaltyID);
    var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    //var regExpPhoneformat = /^[0][1-9]\d{9}$|^[1-9]\d{9}$/g
    //var regExpPhoneformat = /^\+(?:[0-9] ?){6,14}[0-9]$/;
    var regExpPhoneformat = /^\+?(?:[0-9\-] ?){6,14}[0-9]$/;
    //var regExpPhoneformatTwo = /1?[\s-]?\(?(\d{3})\)?[\s-]?\d{3}[\s-]?\d{4}/;
    //var regExpPhoneformatThree = /(([+]?[(]?[0-9]{1,3}[)]?)|([(]?[0-9]{4}[)]?))\s*[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?([-\s\.]?[0-9]{3})([-\s\.]?[0-9]{3,4})/;
    // var regExpName = /^[a-zA-Z ]{2,}$/
    var regExpName = new RegExp("^[a-zA-Z]+([-' ][a-zA-Z]+)*$");
    var regExpLoyalty = new RegExp("^[a-zA-Z0-9]*$");

    if (
      !typeOfRequest ||
      !country ||
      !inputEmail ||
      !firstname ||
      !lastname ||
      (component.get("v.isStateVisible") && !state)
    ) {
      var controlAuraIds = ["firstname", "lastname", "email"];
      let isAllValid = controlAuraIds.reduce(function(
        isValidSoFar,
        controlAuraId
      ) {
        var inputCmp = component.find(controlAuraId);
        inputCmp.reportValidity();
        return isValidSoFar && inputCmp.checkValidity();
      },
      true);

      if (component.get("v.isStateVisible") && !state)
        component.find("state").showHelpMessageIfInvalid("");

      if (!country) component.find("country").showHelpMessageIfInvalid("");

      if (!typeOfRequest)
        component.find("typeOfRequest").showHelpMessageIfInvalid("");

      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please provide all of the required information below"
      );
    } else if (inputEmail && !inputEmail.match(regExpEmailformat)) {
      /*
        if(!typeOfRequest && !country && !inputEmail && !firstname &&!lastname)
        {
            
            helper.showToast(component, event, helper,"error", "Error: ","Please Select Type of Request \n Please Select Country \n Please Provide First Name \n Please Provide Last Name \n Please Provide Email");
        }
        
        else if(!country && !firstname && !lastname && !inputEmail)
        {
            
            helper.showToast(component, event, helper,"error", "Error: ","Please Select Country of Residence \n Please Provide First Name \n Please Provide Last Name \n Please Provide Email");
        }
        
        else if(!country && !inputEmail)
        {
            
            helper.showToast(component, event, helper,"error", "Error: ","Please Select Country of Residence \n Please Provide Email");
        }

        
        else if(!typeOfRequest)
        {
            helper.showToast(component, event, helper,"error", "Error: ","Please Select Type of Request");
        }
        else if(!country)
        {
            helper.showToast(component, event, helper,"error", "Error: ","Please Select Country of Residence");
        }
        
        else if(country==='United States of America (USA)' && !state)
        {
            helper.showToast(component, event, helper,"error", "Error: ","Please Select State of Residence");
        }
        
        
        else if((!firstname || !lastname) && !inputEmail)
        {
            helper.showToast(component, event, helper,"error", "Error: ","Please Provide Both: First Name and Last Name \n Please Provide Email");
        }
        
        else if((!firstname || !lastname))
        {
            helper.showToast(component, event, helper,"error", "Error: ","Please Provide Both: First Name and Last Name");
        }
        
        else if(!inputEmail)
        {
                helper.showToast(component, event, helper,"error", "Error: ","Please Provide Email");
        }
        */
      //component.find("email").setCustomValidity("You have entered invalid email");
      //component.find("email").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please Provide Valid Email"
      );
    } else if (inputPhone && !inputPhone.match(regExpPhoneformat)) {
      //component.find("phone").setCustomValidity("You have entered invalid phone number");
      //component.find("phone").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please Provide Valid Phone Number"
      );
    } else if (inputLoyaltyID && !inputLoyaltyID.match(regExpLoyalty)) {
      component
        .find("loyaltyID")
        .setCustomValidity("You have entered an invalid Loyalty ID");
      component.find("loyaltyID").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please Only Enter Letters and Numbers for Loyalty ID"
      );
    } else if (
      firstname &&
      firstname.trim().length < 2 &&
      lastname &&
      lastname.trim().length < 2
    ) {
      component
        .find("firstname")
        .setCustomValidity("First Name must be minimum 2 characters");
      component.find("firstname").reportValidity();

      component
        .find("lastname")
        .setCustomValidity("Last Name must be minimum 2 characters");
      component.find("lastname").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "First Name and Last Name should be minimum 2 characters"
      );
    } else if (firstname && firstname.trim().length < 2) {
      component
        .find("firstname")
        .setCustomValidity("First Name must be minimum 2 characters");
      component.find("firstname").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "First Name must be minimum 2 characters"
      );
    } else if (lastname && lastname.trim().length < 2) {
      component
        .find("lastname")
        .setCustomValidity("Last Name must be minimum 2 characters");
      component.find("lastname").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Last Name must be minimum 2 characters"
      );
    } else if (
      firstname &&
      !firstname.match(regExpName) &&
      lastname &&
      !lastname.match(regExpName)
    ) {
      component
        .find("firstname")
        .setCustomValidity("Please Provide Valid First Name");
      component.find("firstname").reportValidity();

      component
        .find("lastname")
        .setCustomValidity("Please Provide Valid Last Name");
      component.find("lastname").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please Provide Valid First Name and Last Name"
      );
    } else if (firstname && !firstname.match(regExpName)) {
      component
        .find("firstname")
        .setCustomValidity("Please Provide Valid First Name");
      component.find("firstname").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please Provide Valid First Name"
      );
    } else if (lastname && !lastname.match(regExpName)) {
      component
        .find("lastname")
        .setCustomValidity("Please Provide Valid Last Name");
      component.find("lastname").reportValidity();
      helper.showToast(
        component,
        event,
        helper,
        "error",
        "Error: ",
        "Please Provide Valid Last Name"
      );
    } else {
      helper.handleCreateCase(component, event, helper);
    }
  }
});