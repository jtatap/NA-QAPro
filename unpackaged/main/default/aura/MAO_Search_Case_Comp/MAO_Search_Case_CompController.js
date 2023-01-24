({
    doInit : function (component, event, helper) {
        component.set ('v.sValue', component.get ('v.selectedId') ? 'sByContact' : 'sByOid');
        component.set ('v.manualContactRecord', {'FirstName':'', 'LastName':'', 'Email':'', 'Phone':''});
        
    },
    handleChange: function (component, event) {
        if (event.getParam("value") === 'sByContact') {
            component.set ('v.clickedTabLabel', 'Customer search');
        } else if (event.getParam("value") === 'sByFreeForm') {
            component.set ('v.clickedTabLabel', 'Free form search');
        }
    },
    handleComponentEvent:function(component, event, helper) {
        //component.set ('v.isSearchDisabled', true);
        let message = event.getParam("message");
        console.log('Entered into the eventPVh'+ JSON.stringify(message));
        if (message && message.length > 0) {
            component.set("v.selectedId",message[0].Id);
            component.find("contactRecordHandler").reloadRecord();
        }
    },
    onContactChange : function(component, event, helper) {
        //component.set ('v.isSearchDisabled', true);
        component.set ('v.contactRecord', null);
        component.set ('v.contactRecordLoadError', null);
        if (event.getParam("value") && component.find("contactRecordHandler")) {
            component.find("contactRecordHandler").reloadRecord();
        }
    },
    handleCaseRecordUpdated : function (component, event, helper) {
        let changeType = event.getParams().changeType;
        
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            /* handle record load */ 
            let contactId = component.get ('v.caseRecord').ContactId;
            component.set ('v.selectedId', contactId);
            component.set ('v.caseContactId', contactId);
            if (!component.get ('v.isFirstTime')) {
                component.set ('v.sValue', component.get ('v.selectedId') ? 'sByFreeForm' : 'sByOid');
                component.set ('v.isFirstTime', true);
            }
            
            component.set ('v.orderId', component.get ('v.caseRecord').Order_Number__c);
            
            component.set ('v.isCaseDetailsLoaded', true);
            if (component.find("contactRecordHandler")) {
                component.find("contactRecordHandler").reloadRecord();
            }
            /*if (component.find("currentCasecontactRecordHandler")) {
                component.find("currentCasecontactRecordHandler").reloadRecord();
            }*/
        }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { 
                    /* handle record change */ 
                    component.find("caseRecordLoader").reloadRecord();
                }
    },
    handleCaseContactRecordUpdated : function (component, event, helper) {
        let changeType = event.getParams().changeType;
        
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            /* handle record load 
        }
    	else if (changeType === "REMOVED") { /* handle record removal */ }
            else if (changeType === "CHANGED") { 
                /* handle record change */ 
                component.find("currentCasecontactRecordHandler").reloadRecord();
            }
    },
    handleContactRecordUpdated : function (component, event, helper) {
        let changeType = event.getParams().changeType;
        
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            /* handle record load */ 
            //let contactRecord = component.get ('v.contactRecord');
            //let isSearchDisabled = !contactRecord || contactRecord && !contactRecord.Ecomm_Connected__c;
            //component.set ('v.isSearchDisabled', isSearchDisabled);
        }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { 
                    /* handle record change */ 
                    component.find("contactRecordHandler").reloadRecord();
                }
        //console.log (JSON.stringify (component.get ('v.contactRecord')));
    },
    handleCancel : function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire ();
    },
    handleSubmitOrderId :  function (component, event, helper) {
        var ecommsite = component.get("v.selectedEcommSite");
        if(ecommsite==null || ecommsite=='' || ecommsite==undefined){
            component.set("v.ecommSiteErrorMessage",'Please select Ecomm website.');
        }
        else{
            component.set("v.ecommSiteErrorMessage",'');
            let orderId = component.get ('v.orderId');
            let params = [];
            if (orderId) {
                params.push ('orderId=' + orderId.trim ());
                let caseContact = component.get ('v.contactRecord');
                var selectedEcommSite = component.get("v.selectedEcommSite");
                console.log('-- check1--',selectedEcommSite);
                if(selectedEcommSite!='' || selectedEcommSite!=undefined){
                    params.push ('selectedOrg='+selectedEcommSite);
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
            }
            helper.navigateToURL (component, params, true);
        }
    },
    handleSubmit : function (component, event, helper) {
        var ecommsite = component.get("v.selectedEcommSite");
        if(ecommsite==null || ecommsite=='' || ecommsite==undefined){
            component.set("v.ecommSiteErrorMessage",'Please select Ecomm website.');
        }
        else{
            component.set("v.ecommSiteErrorMessage",'');
            component.set ('v.freeFormErrorMessage', '');
            let sValue = component.get ('v.sValue');
            
            let params = [];
            let isEComConnected;
            switch (sValue) {
                case 'sByOid' :
                    let orderId = component.get ('v.orderId');
                    if (orderId && orderId.trim()) {
                        params = helper.getParamsByOrderId (component);    
                    } else {
                        //show error
                        alert ('invalid order Id')
                    }
                    helper.navigateToURL (component, params, true);
                    break;
                case 'sByContact' :
                    let selectedId = component.get ('v.selectedId');
                    let caseContactId = component.get ('v.caseContactId');
                    
                    if (!selectedId) {
                        //show error
                        alert ('invalid contact Id');
                        break;
                    }
                    
                    if (selectedId === caseContactId) {
                        params = helper.getParamsByContact (component, component.get ('v.contactRecord'));
                        helper.navigateToURL (component, params, false);
                    } else {
                        helper.updateCaseContact (component);
                    }
                    break;
                case 'sByFreeForm' :
                    let ordId = component.get ('v.orderId');
                    let manualContactRecord = component.get ('v.manualContactRecord');
                    if (!ordId 
                        //&& !manualContactRecord
                        && (!manualContactRecord.FirstName && !manualContactRecord.LastName && !manualContactRecord.Email && !manualContactRecord.Phone)
                       ) {
                        component.set ('v.freeFormErrorMessage', 'Please fill order id or contact details');
                        break;
                    }
                    if (ordId && ordId.trim()) {
                        params = helper.getParamsByOrderId (component);    
                    }
                    params = params.concat (helper.getParamsByFreeFormContact (component, component.get ('v.manualContactRecord')));
                    helper.navigateToURL (component, params, false);
                    break;
            }
        }
    },
    handleOnOrdeIdChange: function (component, event, helper) {
        component.set ('v.freeFormErrorMessage', '');
        if (event.getParam("value")) {
            component.set ('v.manualContactRecord', {'FirstName':'', 'LastName':'', 'Email':'', 'Phone':''});
            component.set ('v.isContactFormDisabled', true);
        } else {
            component.set ('v.isContactFormDisabled', false);
        }
    },
    handleOnContactDetailChange : function (component, event, helper) {
        component.set ('v.freeFormErrorMessage', '');        
        if (event.getParam("value")) {
            component.set ('v.orderId', null);
            component.set ('v.isOrderIdDisabled', true);
        } else {
            let manualContactRecord = component.get ('v.manualContactRecord');
            if (!manualContactRecord.FirstName 
                && !manualContactRecord.LastName 
                && !manualContactRecord.Email 
                && !manualContactRecord.Phone) {
                component.set ('v.isOrderIdDisabled', false);    
            }
        }
    },
    enforceFormat : function (component, event, helper) {
        if(!helper.isNumericInput(event) && !helper.isModifierKey(event)){
            event.preventDefault();
        }
    },
    formatToPhone : function (component, event, helper) {
        
        const targetVal = component.get ('v.manualContactRecord.Phone');
        const input = targetVal
        .replace (/\s{2,}/g, "")
        .replace (/\({2,}/g, "(")
        .replace (/\){2,}/g, ")")
        .replace (/\-{2,}/g, "-")
        .replace (/\+{2,}/g, "+");
        helper.isValidPhoneFormat (component, input);
        component.set ('v.manualContactRecord.Phone', input);
        //if(helper.isModifierKey(event) && !helper.isEnabledCharacters (event)) {
        //    return;
        //}
        
        
        //replace(/\D/g,'').substring(0,10); // First ten digits of input only
        //const zip = input.substring(0,3);
        //const middle = input.substring(3,6);
        //const last = input.substring(6,10);
        
        //`(${zip}) ${middle} - ${last}`;
        //if(input.length > 6){component.set ('v.manualContactRecord.Phone', `(${zip}) ${middle}-${last}`);}
        //else if(input.length > 3){component.set ('v.manualContactRecord.Phone',`(${zip})${middle}`);}
        //else if(input.length > 0){component.set ('v.manualContactRecord.Phone',`${zip}`);}
    },
    handleChangeEcommSite : function(component,event, helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedEcommSite",selectedOptionValue);
    }
})