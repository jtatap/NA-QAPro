({
	doInit : function(component, event, helper) {
		var action = component.get("c.getContactDetails");
        action.setParams ({"contactId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                //component.set("v.showTemplate", response.getReturnValue());
                //var verEmail = component.get("v.showTemplate");
                if (response.getReturnValue() != ''){
         		   component.set ("v.msg1",response.getReturnValue());
        		}    
        		else{
        			component.set ("v.Proceed",true)
   	    		}
            } else {
                console.log('Problem getting Contact, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
        
        var action3 = component.get("c.getOldMail");
        action3.setParams ({"contactId": component.get("v.recordId")});
        action3.setCallback(this, function(response3) {
            var state3 = response3.getState();
            if(state3 == "SUCCESS") {
                component.set("v.oldMailId", response3.getReturnValue());
                
        		var oldEmail =component.get("v.oldMailId");
            } else {
                console.log('Problem getting Contact, response state: ' + state3);
            }
        });
        $A.enqueueAction(action3);
	},
    
    submit : function(component, event, helper) {
        component.set ('v.isLoading', true);
        //component.set("v.msg",'Loading...');
        var action1= component.get("c.searchMail");
        action1.setParams({"mailId": component.get("v.newMailId")});
        action1.setCallback(this,function(response1){
            var state1 = response1.getState();
            if (state1 == "SUCCESS") {
                component.set("v.mailExists", response1.getReturnValue());
                var mailExist = component.get("v.mailExists");
                if (mailExist == false){
                    component.set ('v.isLoading', false);
                    component.set ("v.msg","The email address already exists. Please enter a different email address.");
                } else{
                    var action2= component.get("c.updateCSREmailField");
                    action2.setParams({"mailId": component.get("v.newMailId"),
                                      "contactId": component.get("v.recordId")});
                    action2.setCallback(this,function(response2){
                        var state2 = response2.getState();
                        if (state2 == "SUCCESS") {
                            component.set ('v.isLoading', false);
                        	component.set("v.msg",'The Verification Email sent to the old email address: '+component.get("v.oldMailId"));
                            //$A.get("e.force:closeQuickAction").fire();
                        }
                        else{
                            alert('State2 has error: '+response2.getError());
                        }
                    });
                    $A.enqueueAction(action2);
                	/*var input_variable = [
          			{name : "recordId",type : "String",value : component.get("v.recordId")},
                    {name : "newMailId",type : "String",value : component.get("v.newMailId")}    
        			];
                	var flow = component.find("flowId");
                    component.set ("v.msg","Mail has been triggered to old mail Address");
    				flow.startFlow("EmailChange_by_CSR",input_variable);*/
                }
                
                
            } 
            else {
                console.log('Problem getting status, response state: ' + state1);
            }
        });
        $A.enqueueAction(action1);
    	},
    cancelClick : function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();    
    }  
    
})