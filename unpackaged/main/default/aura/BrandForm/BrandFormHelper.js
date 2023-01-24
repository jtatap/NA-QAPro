({
   
	loadInitialData : function(component, event, helper) {
		
        var brandName = component.get("v.brandName");
        var caseSourceCountry = component.get("v.caseSourceCountry");
        
        var appEvent = $A.get("e.c:appBrandNameEvent");
        appEvent.setParam("brandName", brandName);
		appEvent.fire();
        component.set("v.fileIsLoading", false);
        if(brandName=='84')
        {
            component.set("v.newCase.Channel__c",'styleBureau.com');
        }
        else if(brandName=='10')
        {
            component.set("v.newCase.Channel__c",'Other Retailer');
        }
        else if(brandName=='11')
        {
            component.set("v.newCase.Channel__c",'trueandco.com');
        }
    
         
		var action = component.get("c.getData");
        action.setParams({
            'brandName' : brandName,
            'sourceCountry' : caseSourceCountry
           
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var getResults = response.getReturnValue();
                console.log('***We got Response = '+getResults);
                console.log('We got Que 1 Picklist = '+getResults.listQue0);

                //expects data in JSON format: {"options":[{"label","LABEL1","value":"VALUE1"},{"label","LABEL2","value":"VALUE2"}]}
                if (getResults.listQue0) {
                    var reachListArr = JSON.parse(getResults.listQue0).options;

                    component.set("v.reachList", reachListArr);
                } else {
                    component.set("v.reachList", undefined);
                }
                component.set("v.purchaseList",getResults.listQue1);

                if (getResults.listQue3) {
                    var helpListArr = JSON.parse(getResults.listQue3).options;

                    component.set("v.helpList", helpListArr);
                } else {
                    component.set("v.helpList", undefined);
                }
                if (getResults.listQue4) {
                    var teamListArr = JSON.parse(getResults.listQue4).options;

                    component.set("v.TeamList", teamListArr);
                } else {
                    component.set("v.TeamList", undefined);
                }
                
                component.set("v.successMessage",getResults.successMessage);
                
                if(component.get("v.reachList") != undefined)
                {
                    component.set("v.isQuestion",true);
                }
                if(component.get("v.TeamList") != undefined)
                {
                    component.set("v.isTrueNCo",true);
                }
                var userId = getResults.userId;
                console.log(userId);
                component.set("v.recordId", userId);
                
            }
        });
        $A.enqueueAction(action);
        
   //setting the site variables to support order tracking for ck
       if(window.location.href.includes("calvinklein.ca"))
        {
            component.set("v.isUrlCA",true);  
        }
        else if (window.location.href.includes(".com")  || window.location.href.includes(".us"))
        {
            component.set("v.isUrlUS",true);
        }
	},
    
    handleOnChangeReachList : function(component, event, helper) {
       var selectedOption = component.find("reach").get("v.value");
        if(selectedOption.includes(".com")  || selectedOption.includes(".us"))
        {
            component.set("v.isMessage",true);
            component.set("v.isMessageCA",false);
        }
        else if(selectedOption.includes(".ca"))
        {
            component.set("v.isMessageCA",true);
            component.set("v.isMessage",false);
        }
        
            else
            {
                component.set("v.isMessage",false);
                component.set("v.isMessageCA",false);
            }
        console.log(component.get("v.isMessage"));
        
    },
    
    handleExistingPurchase : function(component, event, helper) {
       var selectOption = component.find("purchase").get("v.value");
        if (selectOption === "Yes")
        {
            component.set("v.isExistingPurchase",true);
        } 
        else if (selectOption === "No")
        {
            component.set("v.isExistingPurchase",false);
        }
    },
    
    handlePurchaseTeam : function(component, event, helper) {
       var selectOption = component.find("team").get("v.value");
         if (selectOption === "Amazon.com")
        {
            component.set("v.isAmazon",true);
        }else{
            component.set("v.isAmazon",false);
        } 
    },
    
    setMessage : function(component, event, helper) {
       var selectOption = component.find("help").get("v.value");
        
        if (selectOption === "Order")
        {
            component.set("v.isOrder",true);
        } if(selectOption != "Order")
        {
            component.set("v.isOrder",false);
        }
        
        if (selectOption === "Shipping")
        {
            component.set("v.isShipping",true);
        }
        if(selectOption != "Shipping"){
            component.set("v.isShipping",false);
        } 
        if (selectOption === "Exchange/Returns")
        {
            component.set("v.isReturns",true);
        } 
        if(selectOption != "Exchange/Returns"){
            
            component.set("v.isReturns",false);
        }
    },

    
    
    handleCheckBoxChange : function(component, event, helper) {
        console.log(event.getSource().get('v.checked'));
        var resultCheck = event.getSource().get('v.checked');
        if(resultCheck)
        {
            component.set("v.newCase.Tommy_Adaptive__c",true);
        }
        else
        {
            component.set("v.newCase.Tommy_Adaptive__c",false);
        }
        
    },
    
    
    handleSubmit : function(component, event, helper) {
		console.log('***Helper - inside Submit');
       
        debugger;
        // component.set("v.isFinished",true);
        component.find("firstname").setCustomValidity("");
        component.find("firstname").reportValidity();
        
        component.find("lastname").setCustomValidity("");
        component.find("lastname").reportValidity();
        
        component.find("email").setCustomValidity("");
        component.find("email").reportValidity();
        
        component.find("phone").setCustomValidity("");
        component.find("phone").reportValidity();
        
        var newCase = component.get("v.newCase");
        
        var fNameValid = component.find("firstname");
        
        var fName = fNameValid.get("v.value");
       
        var lNameValid = component.find("lastname");
       
        var lName = lNameValid.get("v.value");
        var brandName = component.get("v.brandName");
        var inputEmailValid = component.find("email");
        var inputEmail = inputEmailValid.get("v.value");
        
        var inputPhoneValid = component.find("phone");
        var inputPhone = inputPhoneValid.get("v.value");
        
        if(component.get("v.isQuestion"))
        {
            var inputReachValid = component.find("reach");
            var inputReach = inputReachValid.get("v.value");
        }
        
        var inputHelpValid = component.find("help");
        var inputHelp = inputHelpValid.get("v.value");
        
        if(component.get("v.isTrueNCo"))
        {
            var inputTeamValid = component.find("team");
            console.log('***inputTeamValid = '+inputTeamValid);
            var inputTeam = inputTeamValid.get("v.value");
            console.log('***inputTeam = '+inputTeam);
        }
        var inputPurchaseValid = component.find("purchase");
        var inputPurchase = inputPurchaseValid.get("v.value");
        
         var inputMessageValid = component.find("message");
        var inputMessage = inputMessageValid.get("v.value");
        
        /*fetching order number:  only when .com .us .ca and brand is 11 or brand is 84.
        if(component.get("v.isMessage") || component.get("v.isMessageCA") || brandName == '11' || brandName == '84' )
        {
        	var orderNumber = component.find("orderNumber").get("v.value");
            var isOrderNumberDisplay = true;
        }
        */
        
        // fetching order number:  only when .com .us .ca and brand is 11 or brand is 84.
        if(component.get("v.isExistingPurchase") && (component.get("v.isMessage") || component.get("v.isMessageCA") || brandName == '11' || brandName == '84' ))
        {
        	var orderNumber = component.find("orderNumber").get("v.value");
            var isOrderNumberDisplay = true;
        }
        
        
        
        //var category = component.find("category").get("v.value");
        //var subCategory = component.find("subcategory").get("v.value");
        //console.log('***Name of Customer = '+fName+' '+lName);
        //console.log('***Type = '+newCase.Type);
        //console.log('***Sub Type = '+newCase.Sub_Type__c);
        //console.log('***Category = '+newCase.Product_Category__c);
        //console.log('***Sub Category = '+newCase.Product_Sub_Category__c);
        //console.log('***Reach = '+newCase.Channel__c);
		
        // var fileInput = component.find("fileId").get("v.files");
        var fileInput = component.get("v.fileArray");
        //console.log('fName = '+fName);
        //console.log('lName = '+lName);
        //console.log('inputEmail = '+inputEmail);
        console.log('inputPurchase = '+inputPurchase);
        //console.log('inputMessage = '+inputMessage);
        //console.log('***File Input = '+fileInput);
        //console.log('category = '+category);
        //console.log('subCategory = '+subCategory);
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        
        //var regExpName = /^[a-zA-Z]{2,}$/
        var regExpName = new RegExp('^[a-zA-Z]+([-\' ][a-zA-Z]+)*$');
        //var regExpName = /^[a-zA-Z'-]{2,}|^[a-zA-Z'-]{2,}[\s\D]+/;
       //NAVCM-417 
       // var regExONTrue = /^[0-9]{7}$/;
        var regExONAllBrands = /^[0-9]{8}$/;
        var regExpPhoneformat = /^\+?(?:[0-9\-] ?){6,15}[0-9]$/;
        //var regExpPhoneformatTwo = /1?[\s-]?\(?(\d{3})\)?[\s-]?\d{3}[\s-]?\d{4}/;
        //var regExpPhoneformatThree = /(([+]?[(]?[0-9]{1,3}[)]?)|([(]?[0-9]{4}[)]?))\s*[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?([-\s\.]?[0-9]{3})([-\s\.]?[0-9]{3,4})/;
        //var regExpPhoneformat = "(^\+(?:[0-9\-] ?){6,15}[0-9]$|1?[\s-]?\(?(\d{3})\)?[\s-]?\d{3}[\s-]?\d{4}|(([+][(]?[0-9]{1,3}[)]?)|([(]?[0-9]{4}[)]?))\s*[)]?[-\s\.]?[(]?[0-9]{1,3}[)]?([-\s\.]?[0-9]{3})([-\s\.]?[0-9]{3,4}))"
        //var regExpPhoneformatNorthAmerica = /^\(?([0-9]{3})\)?[-.●]?([0-9]{3})[-.●]?([0-9]{4})$/;
        
        if(!fName || !lName || !inputEmail || !inputPurchase || !inputMessage || (component.get("v.isQuestion") && !inputReach) || !inputPurchase || !inputHelp || (component.get("v.isTrueNCo") &&!inputTeam))
        {
            
            var controlAuraIds = ["firstname","lastname","email","message"];
            let isAllValid = controlAuraIds.reduce(function(isValidSoFar, controlAuraId){
                var inputCmp = component.find(controlAuraId);
                inputCmp.reportValidity();
                return isValidSoFar && inputCmp.checkValidity();
            },true);
            
            
            
            if(component.get("v.isQuestion") && !inputReach)
            	inputReachValid.showHelpMessageIfInvalid('');
            
            if(!inputPurchase)
            	inputPurchaseValid.showHelpMessageIfInvalid('');
            
            if(!inputHelp)
            	inputHelpValid.showHelpMessageIfInvalid('');
            
            if(component.get("v.isTrueNCo") && !inputTeam)
            	inputTeamValid.showHelpMessageIfInvalid('');
            
            this.showToast(component, event, "error","Error: ","Please provide all of the required information below");
        }
        
        
        else if(inputEmail && !inputEmail.match(regExpEmailformat))
        {
            //component.find("email").setCustomValidity("You have entered invalied email");
            //component.find("email").reportValidity();
            this.showToast(component, event,"error", "Error: ","Please Provide Valid Email");
        }
        else if(inputPhone && !inputPhone.match(regExpPhoneformat))
        {
            //component.find("phone").setCustomValidity("You have entered invalied phone number");
            //component.find("phone").reportValidity();
            this.showToast(component, event,"error", "Error: ","Please Provide Valid Phone Number");
        }
        
        else if((fName && fName.trim().length<2) && (lName && lName.trim().length<2))
        {
            component.find("firstname").setCustomValidity("First Name must be minimum 2 characters");
            component.find("firstname").reportValidity();
            
            component.find("lastname").setCustomValidity("Last Name must be minimum 2 characters");
            component.find("lastname").reportValidity();
            this.showToast(component, event,"error", "Error: ","First Name and Last Name should be minimum 2 characters");
        }
        
        else if(fName && fName.trim().length<2)
        {
        	
            component.find("firstname").setCustomValidity("First Name must be minimum 2 characters");
            component.find("firstname").reportValidity();
            this.showToast(component, event,"error", "Error: ","First Name must be minimum 2 characters");
        }
        
		else if(lName && lName.trim().length<2)
        {
        	
            component.find("lastname").setCustomValidity("Last Name must be minimum 2 characters");
            component.find("lastname").reportValidity();
            this.showToast(component, event,"error", "Error: ","Last Name must be minimum 2 characters");
        }        

        
        
        else if((fName && !fName.match(regExpName)) && (lName && !lName.match(regExpName)))
        {
            component.find("firstname").setCustomValidity("Please Provide Valid First Name");
            component.find("firstname").reportValidity();
            
            component.find("lastname").setCustomValidity("Please Provide Valid Last Name");
            component.find("lastname").reportValidity();
            this.showToast(component, event,"error", "Error: ","Please Provide Valid First Name and Last Name");
        }
        
        else if(fName && !fName.match(regExpName))
        {
            console.log('invalid first name');
            //var inputFirstName = component.find("firstname");
            component.find("firstname").setCustomValidity("Please Provide Valid First Name");
            component.find("firstname").reportValidity();
			this.showToast(component, event,"error", "Error: ","Please Provide Valid First Name");
        }
        
        else if(lName && !lName.match(regExpName))
        {
            component.find("lastname").setCustomValidity("Please Provide Valid Last Name");
            component.find("lastname").reportValidity();
            this.showToast(component, event,"error", "Error: ","Please Provide Valid Last Name");
        }
        
        // if brand is 11 -> then Order Number should be exactly 6 digits 
        // NAVCM-417 
       /* else if(isOrderNumberDisplay && orderNumber && brandName == '11' && !orderNumber.match(regExONTrue))
        {
            this.showToast(component, event,"error", "Error: ","Please Provide Valid Order Number");
        }*/
        
        // if brand is other than 11 -> then Order Number should be exactly 8 digits 
        else if(isOrderNumberDisplay && orderNumber && brandName != '11' && !orderNumber.match(regExONAllBrands))
        {
            this.showToast(component, event,"error", "Error: ","Please Provide Valid Order Number");
        }
        
        
        else
        {
            var fileLimit = component.get('v.fileCountLimit');
            var files = component.get("v.files");
            if(files && files.length > fileLimit)
            {
                console.log('***ERROR - MORE FILES');
                this.showToast(component, event, "error","Error: ","You can only upload a maximum of 5 files.");
            } else {
                this.saveCaseMethod(component, event);
            }
        }
       console.log('***Helper - end of Submit'); 
	},
    saveCaseMethod : function (component, event)
    {
        console.log('***inside Save Case***');
        var newCase = component.get("v.newCase");
        var fName = component.find("firstname").get("v.value");
        var lName = component.find("lastname").get("v.value");
        var brandName = component.get("v.brandName");
       
        
        //var fileInput = component.find("fileId").get("v.files");
		//var fileInput = component.get("v.fileArray");
		var files = component.get("v.files");

        var saveAction = component.get("c.createCase");
        
        saveAction.setParams({ 
            "getCaseDetail": newCase,
            "firstName": fName,
            "lastName": lName,
            "name" : fName+' '+lName,
            "brandName" : brandName
        });
        
        saveAction.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                
                //$A.get('e.force:refreshView').fire(); 
                var result = a.getReturnValue();
                console.log('***Case Id = '+result.caseId);
                console.log('***Case No = '+result.caseNumber);
                
                component.set("v.parentId",result.caseId);
                component.set("v.ticketid",result.caseNumber);
                // component.set("v.isFinished", true);
                //console.log('***Case No = '+component.get("v.ticketid"));
                //console.log('***Case Id = '+component.get("v.parentId"));
                //after case creation - we need to upload file
                if (files && files.length > 0) {
                    //this.uploadHelper(component, event);
                    this.assignFilesToCase(component, event);
                    component.set("v.isFinished", true);
                } else {
                    console.log('No Files Given to Attach. So Case Created Without File');
                    component.set("v.isFinished", true);
                    
                }
                
            }
            else if (state === "INCOMPLETE") {
                console.log('***INCOMPLETE')
            }
            else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                      this.showToast(component, event, "error","Error: ","Something Went Wrong.");  
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(saveAction)
    },
    assignFilesToCase: function(component, event) {
        var files = component.get("v.files");

        var fileIds = [];
        for (var f in files) {
            if (files.hasOwnProperty(f)) {
                fileIds.push(files[f].Id);
            }
        }

        var caseId = component.get("v.parentId");

        var action = component.get("c.assignFilesToCase");
        action.setParams({
            files: fileIds,
            caseId: caseId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('files reassigned');
            } else if (state === "INCOMPLETE") {

            }  else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },
    showToast : function(component, event,displayType,displayTitle,errorMessage) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : displayType,
            "title": displayTitle,
            "duration": 8000,
            "message": errorMessage
        });
        toastEvent.fire();
    },
    delUploadedfiles : function(component,documentId) {
        var action = component.get("c.deleteFiles");
        action.setParams({
            "sdocumentId":documentId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    }
})