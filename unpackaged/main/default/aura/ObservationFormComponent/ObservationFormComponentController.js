({
    doInit : function(cmp, event, helper) {
       
        
        var recId = cmp.get("v.recordId");
        var success = String($A.get("$Label.c.Success1"));
        var incomplete = String($A.get("$Label.c.Incomplete"));
        var error = String($A.get("$Label.c.Error1"));
        var action = cmp.get("c.getCaseOrigin");
        action.setParams({ caseId : recId });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === success) {
                // Alert the user with the value returned 
                // from the server
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
    
    
})