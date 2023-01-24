({
    doInit : function(cmp, event, helper) {
        //alert('inside doInit');
        
        var recId = cmp.get("v.recordId");
        //alert('Case Id = '+recId);
        
        var action = cmp.get("c.getCaseOrigin");
        action.setParams({ caseId : recId });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                var recordTypeToSet = response.getReturnValue();
                
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Observation_Form__c",  // sObject API Name [Required Parameter]
                    "recordTypeId": recordTypeToSet, // Optionally Specify Record Type Id
                    
                    "defaultFieldValues": {
                        'Case__c' : recId
                    }
                    
                });
                createRecordEvent.fire();
                
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
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
    
    /*
    doRender : function(cmp, event, helper) {
        this.superRender();
    alert('called doRender');
    },
     doReRender : function(cmp, event, helper) {
         this.superRender();
     alert('called doReRender');
    },
    doUnRender : function(cmp, event, helper) {
        this.superRender();
    alert('called doUnRender');
    }
    */
    
    
})