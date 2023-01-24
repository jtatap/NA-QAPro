({
    handleComponentEvent:function(component, event, helper) {
        var message = event.getParam("message");
        console.log('Entered into the eventPVh'+ JSON.stringify(message));
        for (let i = 0; i < message.length; i++){
            name=message[i].Id;
            console.log("You selected: " + message[i].Id);
            component.set("v.selectedId",message[i].Id);
            //component.set("v.selectedName",message[i].Name);
            
        }
        
    },
    updateRecord:function(component, event, helper) {
        console.log('-- record id--',component.get("v.recordId"));
        var id = component.get("v.recordId") ;
        component.set("v.simpleRecord.ContactId",component.get("v.selectedId")); 
        component.find("recordHandler").saveRecord($A.getCallback(function(response) {
            if (component.isValid() && response.state == "SUCCESS") {
                console.log('Entered into the success');
            } else if (response.state == "ERROR") {
                //It is always entering here.
                console.log('Entered into the error--',response);
            }
        }));
    }
})