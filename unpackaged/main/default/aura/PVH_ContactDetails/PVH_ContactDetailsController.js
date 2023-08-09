({
	handleComponentEvent:function(component, event, helper) {
        var message = event.getParam("message");
        console.log('Entered into the eventPVh'+ JSON.stringify(message));
      for (let i = 0; i < message.length; i++){
             name=message[i].Id;
        console.log("You selected: " + message[i].Id);
            component.set("v.selectedId",message[i].Id);
            
             
    }
       
    },
    updateRecord:function(component, event, helper) {
        
         var id = component.get("v.recordId") ;
         var error = String($A.get("$Label.c.Error1"));
         var success = String($A.get("$Label.c.Success1"));
        
        component.set("v.simpleRecord.ContactId",component.get("v.selectedId")); 
        component.find("recordHandler").saveRecord($A.getCallback(function(response) {
            if (component.isValid() && response.state == success) {
                 console.log('Entered into the success');
            } else if (response.state == error) {
                //It is always entering here.
                 console.log('Entered into the error');
            }
        }));
    }
})