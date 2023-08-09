({
	getParamsByContact : function (component, contactRecord) {
		let params = [];
        
        if (contactRecord){
            if (contactRecord.FirstName && component.find("cb_firstName").get("v.checked")) {
                params.push ('FirstName='+contactRecord.FirstName.trim ());
            }
            if (contactRecord.LastName && component.find("cb_lastName").get("v.checked")) {
                params.push ('LastName='+contactRecord.LastName.trim ());
            }
            if (contactRecord.Email && component.find("cb_email").get("v.checked")) {
                params.push ('Email='+contactRecord.Email.trim ());
            }
            if (contactRecord.Phone && component.find("cb_phone").get("v.checked")) {
                params.push('Phone='+(contactRecord.Phone.trim ()));
            }
            if(component.get("v.selectedEcommSite")){
                params.push ('selectedOrg='+component.get("v.selectedEcommSite"));
            }else{
            if (!contactRecord.EcommSite__c
               	|| (contactRecord.EcommSite__c && contactRecord.EcommSite__c === 'None')
                || (contactRecord.EcommSite__c && (contactRecord.EcommSite__c === 'CK-US') )
               ) {
				params.push ('selectedOrg=CK');
            } else if (contactRecord.EcommSite__c && contactRecord.EcommSite__c === 'CK-CA'){
                params.push ('selectedOrg=' + contactRecord.EcommSite__c);
            }
            }
        }
        
        return params;
	},
    getParamsByFreeFormContact : function (component, contactRecord) {
		let params = [];
        
        if (contactRecord) {
            
            if ((contactRecord.FirstName && !contactRecord.LastName)
               	||(contactRecord.LastName && !contactRecord.FirstName)
               ) {
                component.set ('v.freeFormErrorMessage', 'Please fill both First Name and Last Name if you are searching by Name');
                return [];
            }
            
            //if (!contactRecord.Phone 
                //&& (contactRecord.FirstName && contactRecord.LastName && contactRecord.Email)
               //) {
                //component.set ('v.freeFormErrorMessage', 'Please enter First Name, Last Name, Email and Phone');
                //return [];
            //}
            
            
            if (contactRecord.FirstName) {
                params.push ('FirstName='+contactRecord.FirstName.trim ());
            }
            if (contactRecord.LastName) {
                params.push ('LastName='+contactRecord.LastName.trim ());
            }
            if (contactRecord.Email) {
                params.push ('Email='+contactRecord.Email.trim ());
            }
            if (contactRecord.Phone) {
                params.push ('Phone='+(contactRecord.Phone.trim ()))
            }
        }
        
        let caseContact = component.get ('v.contactRecord');
        if(component.get("v.selectedEcommSite")){
           params.push ('selectedOrg='+component.get("v.selectedEcommSite"));
        }else{
        if (caseContact) {
            if (!caseContact.EcommSite__c
               	|| (caseContact.EcommSite__c && caseContact.EcommSite__c === 'None')
                || (caseContact.EcommSite__c && (caseContact.EcommSite__c === 'CK-US') )
               ) {
				params.push ('selectedOrg=CK');
            } else if (caseContact.EcommSite__c && caseContact.EcommSite__c === 'CK-CA'){
                params.push ('selectedOrg=' + caseContact.EcommSite__c);
            }
        }
        }
        
        return params;
	},
    getParamsByOrderId : function (component) {
        let orderId = component.get ('v.orderId');
        let params = [];
        if (orderId) {
            params.push ('orderId=' + orderId.trim ());
        }
        return params;
    },
    updateCaseContact : function (component) {
        let caseRecord = component.get ('v.caseRecord');
        var success = String($A.get("$Label.c.Success1"));
        var incomplete = String($A.get("$Label.c.Incomplete"));
        var error = String($A.get("$Label.c.Error1"));
        var draft = String($A.get("$Label.c.Draft"));
        component.set ('v.previousCaseContactId', component.get ('v.caseContactId'));
        caseRecord.ContactId = component.get ('v.selectedId');
        component.set ('v.caseRecord', caseRecord);
        component.set ('v.isLoading', true);
        let self = this;
        component.find("caseRecordLoader").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === success || saveResult.state === draft) {
                component.set ('v.caseContactId', component.get ('v.caseRecord.ContactId'));
                if (component.find("currentCasecontactRecordHandler")) {
                    component.find("currentCasecontactRecordHandler").reloadRecord();
                }
                let params = self.getParamsByContact (component, component.get ('v.contactRecord'));
                self.navigateToURL(component, params, false);
            } else if (saveResult.state === incomplete) {
                console.log("User is offline, device doesn't support drafts.");
                component.set ('v.caseContactId', component.get ('v.previousCaseContactId'));
            } else if (saveResult.state === error) {
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                component.set ('v.caseContactId', component.get ('v.previousCaseContactId'));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                component.set ('v.caseContactId', component.get ('v.previousCaseContactId'));
            }
            component.set ('v.isLoading', false);
        }));
    },
    navigateToURL : function (component, params, isOrder) {
        if (params && params.length > 0) {
            let completeURL =isOrder ? $A.get ('$Label.c.MAO_ORDER_SEARCH_URL') : $A.get ('$Label.c.MAO_CUSTOMER_SEARCH_URL'); 
            let paramText = '';
            if (params && params.length > 0) {
                completeURL += params.join ('&');
            }
        
           
            let windowFeatures = "menubar=no,resizable=yes,scrollbars=yes";
            windowFeatures  = "width=" + screen.width;

            completeURL = completeURL.replace ('+', '%2B');
            component.set ('v.completeURL', completeURL);
            
            let newWin = window.open(completeURL, windowFeatures );
            
            console.log ('completeURL :' + completeURL);
            
            if(!newWin || newWin.closed || typeof newWin.closed=='undefined') { 
                //POPUP BLOCKED
                alert ('Popup blocked, Please allow current site to open popup');
                return;
            }
            
            this.createTaskRecord (component, completeURL);
            
        }
	},
    createTaskRecord : function (component, completeURL) {
        let simpleTask = {};
        let caseRecord = component.get ('v.caseRecord');
        var success = String($A.get("$Label.c.Success1"));
        var incomplete = String($A.get("$Label.c.Incomplete"));
        var error = String($A.get("$Label.c.Error1"));
        var draft = String($A.get("$Label.c.Draft"));
        simpleTask.Subject = 'URL : - '+ component.get ('v.clickedTabLabel');
        simpleTask.Description = completeURL;
        simpleTask.Status = 'Closed';
        simpleTask.Priority = 'Normal';
        simpleTask.WhoId = caseRecord.ContactId;
        simpleTask.WhatId = component.get ('v.recordId');
        simpleTask.TaskSubtype  = 'Email';
        
        let action = component.get ('c.createTask');
        action.setParams ({
            taskRecordStr : JSON.stringify (simpleTask)
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === success) {
                console.log ('response.getReturnValue() :' + response.getReturnValue());
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "message": "The record was saved."
                });
                $A.get('e.force:refreshView').fire();
            }
            else if (state === incomplete) {
                // do something
            }
            else if (state === error) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    removeSpecialCharacters : function (phoneStr) {
    	let cleanedStr = phoneStr.replace (/[^0-9+]/g, "");
        if (! (/^\+1/.test (cleanedStr))) {
            cleanedStr = '+1' + cleanedStr; 
        }
        return cleanedStr;
    },
    formatPhoneNumber : function (phoneNumberString) {
        var cleaned = ('' + phoneNumberString).replace(/\D/g, '');
        var match = cleaned.match(/^(1|)?(\d{3})(\d{3})(\d{4})$/);
        if (match) {
        	var intlCode = (match[1] ? '+1 ' : '');
        	return [intlCode, '(', match[2], ') ', match[3], '-', match[4]].join('');
    	}
     	return phoneNumberString;
 	},
    isNumericInput : function (event) {
        const key = event.keyCode;
        return ((key >= 48 && key <= 57) || // Allow number line
                (key >= 96 && key <= 105) // Allow number pad
		);
    },
    isModifierKey : function (event) {
        const key = event.keyCode;
        return (event.shiftKey === true || key === 35 || key === 36 || key === 32 || key === 109 || key === 189) || // Allow Shift, Home, End
            (key === 8 || key === 9 || key === 13 || key === 46) || // Allow Backspace, Tab, Enter, Delete
            (key > 36 && key < 41) || // Allow left, up, right, down
            (
                // Allow Ctrl/Command + A,C,V,X,Z
                (event.ctrlKey === true || event.metaKey === true) &&
                (key === 65 || key === 67 || key === 86 || key === 88 || key === 90)
            )
    },
    isEnabledCharacters :  function (event) {
        const key = event.keyCode;
        return (key === 32 || key === 187 || key === 107 || key === 109 || key === 189);
    },
    isValidPhoneFormat : function (component, input) {
    	let phoneInput = component.find ('inputPhoneFreeForm');
        let isValid = (/(^\(\d{3}\)|^\d{3})\s?\d{3}[-\s]?\d{4}$/g.test (input))
                        ||
                        (/^(\+)\d{11}$|^\d{11}$/gm.test (input)); 
        if (isValid) {
        	 phoneInput.setCustomValidity('');
        } else {
            if (input.replace(/\D/g,'').substring(0,10).length > 9) {
            } else {
            }
        }
        phoneInput.reportValidity();
        return isValid;
	}
})