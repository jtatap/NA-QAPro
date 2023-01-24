({

init : function(component, event, helper) {
   // helper.getCases(component);
   
},
    
 handleSubmit: function (cmp, event,helper) {
      debugger;
     cmp.find("Id_spinner").set("v.class" , 'slds-show');
       var id = cmp.get("v.recordId") ;
       var subjectField = cmp.find("subject").get("v.value");
       var statusField = cmp.find("status").get("v.value");
       var descField = cmp.find("desc").get("v.value");
       var contactField = cmp.get("v.selectedId");
      console.log('entered into handle submit'+contactField);
      
      var action1 = cmp.get("c.saveCase");
          action1.setParams({"recordId":cmp.get("v.recordId"),
                            "subjectField":cmp.find("subject").get("v.value"),
                            "statusField":cmp.find("status").get("v.value"),
                            "descField":cmp.find("desc").get("v.value"),
                            "contactField":cmp.get("v.selectedId")
                            }); 
      console.log('before response****'); 
      action1.setCallback(this, function(response){
           console.log('response****'); 
           cmp.find("Id_spinner").set("v.class" , 'slds-hide');
         	var status = response.getState();
            console.log('status****'+status); 
          var responseVal = response.getReturnValue();//changed here
           console.log('responseVal****'+responseVal);
               cmp.set("v.childCaseId",responseVal[0].Id);
               var childId=cmp.get("v.childCaseId");
          console.log('childId****'+childId); 
                var workspaceAPI = cmp.find("workspace");
          var workspaceAPI = cmp.find("workspace");
            workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
                workspaceAPI.openSubtab({
                    parentTabId: enclosingTabId,
                    recordId: childId,
                    
                }).then(function(subtabId) {
                    console.log("The new subtab ID is:" + subtabId);
                    
                }).catch(function(error) {
                    console.log("error");
                });
            })
            .catch(function(error) {
                console.log(error);
            });
             if(status === "SUCCESS"){
               console.log('status** Success');   
                 $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                 }
             else if(status === "ERROR"){
              console.log('status** Error'); 
             }
        });
        $A.enqueueAction(action1);
       
     },     

createCase : function(component, event, helper) {
    debugger;
    console.log('Inside** Create Case');
   
    var subjectField = component.find("subject");
    var subject =  subjectField.get("v.value");
    
    var statusField = component.find("status");
    var status =  statusField.get("v.value");
    
    var descField = component.find("desc");
    var description =  contactField.get("v.value");
    
    var contactField = component.find("contact");
    var contact =  contactField.get("v.value");
    console.log('contactField'+contactField);
   //var contact =  contactField.get("v.selectedContact");

    var newCase = component.get('v.newCase');
    newCase.subject = subject;
    newCase.desc = description;
    newCase.status = status;
    newCase.contact = contact;

    console.log(newCase);
    helper.createCase(component, newCase);
    //helper.createCase(component, JSON.stringify(newCase));

    console.log('End of createCase');

},
  handleComponentEvent:function(component, event, helper) {
        var message = event.getParam("message");
        console.log('Entered into the eventPVh'+ JSON.stringify(message));
      for (let i = 0; i < message.length; i++){
             name=message[i].Id;
        console.log("You selected: " + message[i].Id);
            component.set("v.selectedId",message[i].Id);
            //component.set("v.selectedName",message[i].Name);
    }
       // component.set("v.contactRec",message);
       // console.log('Entered into the after set'+ component.get('v.contactRec'));
    }
})