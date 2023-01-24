({
	doInit : function(cmp, event, helper) {
        
        /*
         	cmp.set('v.mycolumns', [
            
                {label: 'Reward Id', fieldName: 'RewardType__c', type: 'text'},
                {label: 'Description', fieldName: 'Description__c', type: 'text'},
                {label: 'Status', fieldName: 'Status__c', type: 'Picklist'},
               
                
            ]);
        */	
		var action = cmp.get("c.getLoyaltyId");
        action.setParams({ recordIds : cmp.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + JSON.stringify(response.getReturnValue()));
				cmp.set("v.rewardWrapper", response.getReturnValue());
                //alert('Rew Type: '+response.getReturnValue()[0].rewardType);
                //alert('Description: '+response.getReturnValue()[0].description);
                //alert('Status: '+response.getReturnValue()[0].status);
                cmp.set("v.numRecords",response.getReturnValue().length);
                
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

        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
	},
    
     handleClick: function(cmp, event, helper) {
        cmp.set("v.pointWrapperObject",null);
        //alert('inside handle click = '+cmp.get("v.pointWrapperObject"));
        //var indexvar = event.getSource().get("v.name");
        var idx = event.target.id;
        //alert('***index = '+idx);
        //var getPointWrapper = cmp.get("v.rewardWrapper")[idx];
        var transactionID = cmp.get("v.rewardWrapper")[idx].transactionId;
        //alert('got transactionID = '+transactionID);
        
        //alert('data = '+getPointWrapper);
        //alert('##'+JSON.stringify(getPointWrapper));
        var gotPointsData = cmp.get("v.pointWrapper");
        console.log('Data = '+JSON.stringify(gotPointsData));
        //alert('Desc = '+gotPointsData[2].Description);
        for (var i = 0; i < gotPointsData.length; i++) {
            //alert('transaction id '+transactionID);
            //alert('index trasaction desc '+gotPointsData[i].Description);
            
            if(gotPointsData[i].Description == transactionID)
            {
                //alert('inside if');
                cmp.set("v.pointWrapperObject",gotPointsData[i]);
            }
            
        }
        //alert('final transaction = '+cmp.get("v.pointWrapperObject"));
         
        if(cmp.get("v.pointWrapperObject") != null)
        {
        $A.createComponent("c:A1_TransactionDetails",
                           {
                               "pointWrapper" :  cmp.get("v.pointWrapperObject")
                           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   //alert('Inside Success');
                                   var modalBody = content;
                                   cmp.find('overlayRewardsDetail').showCustomModal({
                                       //header: "Welcome to Points Detail",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "model12",
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   }).then(function(overlay){
                                       console.log("Overlay is made");
                                   });
                               }
                           });
            
        }
         else
         {
             helper.showToast(cmp, event,"error", "Error: ","Transaction Details Not Found");
         }
    },
 
    handleApplicationEvent : function(cmp, event) { 
        //Get the event message attribute
        var gotPointWrapper = event.getParam("pointWrapperFromEvent"); 
        //Set the handler attributes based on event data 
        cmp.set("v.pointWrapper", gotPointWrapper);   
        //alert('We got Points Data in Rewards Component '+JSON.stringify(cmp.get('v.pointWrapper')));
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
    

})