({
	handleCaseRecordUpdated : function(component, event, helper) {
		let changeType = event.getParams().changeType;

    	if (changeType === "ERROR") { /* handle error; do this first! */ }
    	else if (changeType === "LOADED") { 
            /* handle record load */ 
            let contactId = component.get ('v.caseRecord').ContactId;
            component.set ('v.caseContactId', contactId);
           
            component.set ('v.isCaseDetailsLoaded', true);
            if (component.find("contactRecordHandler") && contactId) {
                component.find("contactRecordHandler").reloadRecord();
            } else {
                component.set ('v.isLoading', false);
            }
        }
    	else if (changeType === "REMOVED") { /* handle record removal */ }
    	else if (changeType === "CHANGED") { 
            /* handle record change */ 
        	component.find("caseRecordLoader").reloadRecord();
        }
	},
    handleContactRecordUpdated : function (component, event, helper) {
		let changeType = event.getParams().changeType;

    	if (changeType === "ERROR") { /* handle error; do this first! */ }
    	else if (changeType === "LOADED") { 
            /* handle record load */ 
           	let contactRecord = component.get ('v.contactRecord');
            
            component.set ('v.isLoading', false);
            
            if (contactRecord && contactRecord.Ecomm_Connected__c) {
                var input_variable = [
                    {name : "recordId",type : "String",value : contactRecord.Id},
                    {name : "asRegistered",type : "Boolean",value : true}    
                ];
                var flow = component.find("flowId");
                flow.startFlow("Order_On_Behalf_for_Physical_Address",input_variable);
            }
        }
    	else if (changeType === "REMOVED") { /* handle record removal */ }
    	else if (changeType === "CHANGED") { 
            /* handle record change */ 
        	component.find("contactRecordHandler").reloadRecord();
        }
    },
})