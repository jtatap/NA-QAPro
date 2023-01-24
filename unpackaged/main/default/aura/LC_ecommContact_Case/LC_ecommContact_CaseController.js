({
    doInit : function(component, event, helper) {
        var action = component.get("c.getContactId");
        action.setParams ({"CaseId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS") {
                var str = response.getReturnValue();
                if (!str.startsWith('003')){
                    component.set("v.msg1", response.getReturnValue());
                }
                /*if(response.getReturnValue() == 'STOP: You must create a contact record or associate contact record with an existing account.'
                   || response.getReturnValue() == 'The Customer Account is disabled.'
                   || response.getReturnValue() == 'The Customer Account is Locked.'){
                    component.set("v.msg1", response.getReturnValue());    
                }*/
                else{
                    component.set("v.ContactExist",true);
                    component.set("v.ContactId", response.getReturnValue());
                    component.set("v.NewContactId", response.getReturnValue());
                    var conId = component.get("v.ContactId");
                    var action2 = component.get("c.eCommConnectedFlag");
                    action2.setParams ({"contactId": component.get("v.ContactId")});
                    action2.setCallback(this, function(response2){
                        var state = response2.getState();
                        if(state == "SUCCESS") {
                            component.set("v.eCommNotConnected", response2.getReturnValue());
                            if(component.get("v.eCommNotConnected") == true){
                                var action1 = component.get("c.eCommOtherCont");
                                action1.setParams ({"contactId": component.get("v.ContactId")});
                                action1.setCallback(this, function(response1){
                                    var state = response1.getState();
                                    if(state == "SUCCESS") {
                                        component.set("v.con", response1.getReturnValue());
                                        component.set("v.NewContactId", response1.getReturnValue().Id);
                                        
                                        component.set("v.otherECommContact",true);
                                        var clm = [
                                            {label:"First Name", fieldName:"FirstName"},
                                            {label:"Last Name", fieldName:"LastName"},
                                            {label:"Email", fieldName:"Email"},
                                            {label:"Loyality Id", fieldName:"LoyaltyID__c"},
                                            {label:"Brand Name", fieldName:"Brand__c"}
                                        ];
                                        component.set("v.col",clm);  
                                    }
                                    else{
                                        var errors = response1.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                //alert("Error message1: " + errors[0].message);
                                            }
                                        } 
                                    }
                                });
                                $A.enqueueAction(action1);
                                
                            }
                        }
                        else{
                            var errors = response.getError();
                            alert('Error is '+ errors);
                        }
                    });
                    $A.enqueueAction(action2);
                }
                
            }
            else{
                //alert("Action is a Failure");
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    confirm :function(component, event, helper) {
        component.set ('v.isLoading', true);
        var action = component.get("c.linkContact");
        action.setParams ({"Cont": component.get("v.con"),
                           "CaseId":component.get("v.recordId") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.NewContactId", response.getReturnValue());
                //alert('Contactid is :'+ component.get("v.NewContactId"));
                component.set("v.msg", "Case linked to EcommConnected Contact");
                component.set ('v.isLoading', false);
                //component.set("v.launchFlow",false);
                var input_variable = [
                    {name : "recordId",type : "String",value : component.get("v.NewContactId")},
                    {name : "asRegistered",type : "Boolean",value : true},
                    {name : "caseId", type : "String" , value : component.get("v.recordId")}  ,
                     {name : "caseRecordId",type : "String",value : component.get("v.recordId")},
                ];
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": component.get("v.recordId"),
                  "slideDevName": "Detail"
                });
                navEvt.fire();
                $A.get('e.force:refreshView').fire();
                console.log('-- check1-->',input_variable);
                //var flow = component.find("flowId");
                //flow.startFlow("OrderOnBehalfOf_Case",input_variable);
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } 
            }
        });
        $A.enqueueAction(action);        
    },
    anonymous :function(component, event, helper){
        component.set("v.launchFlow",false);
        var input_variable = [
            {name : "recordId",type : "String",value : component.get("v.NewContactId")},
            {name : "OldContactId",type : "String",value : component.get("v.ContactId")},
            {name : "caseRecordId",type : "String",value : component.get("v.recordId")},
            {name : "asRegistered",type : "Boolean",value : false}    
        ];
        var flow = component.find("flowId");
        flow.startFlow("OrderOnBehalfOf_Case",input_variable);
    },
    
    registered :function(component, event, helper){
        component.set("v.launchFlow",false);
        var input_variable = [
            {name : "recordId",type : "String",value : component.get("v.NewContactId")},
            {name : "OldContactId",type : "String",value : component.get("v.ContactId")},
            {name : "caseRecordId",type : "String",value : component.get("v.recordId")},
            {name : "asRegistered",type : "Boolean",value : true}    
        ];
        var flow = component.find("flowId");
        flow.startFlow("OrderOnBehalfOf_Case",input_variable);
    },
    handleStatusChange  :function(component, event, helper){
        if(event.getParam("status") === "FINISHED"){
           
        }
        
    },
      cancelClick : function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();    
    }  
  
})