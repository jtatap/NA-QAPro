({
	doInit : function(cmp, event, helper) {
		var getRecord = cmp.get("v.recordId");
        var ifCase = getRecord.startsWith("500");
        cmp.set("v.isCaseRecord",ifCase);
        
        var actionMergeLoyalty = cmp.get("c.checkIsLoyaltyApplicable");
        actionMergeLoyalty.setParams({ recordId : cmp.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        actionMergeLoyalty.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var loyaltyStatus = response.getReturnValue();
                console.log('*****loyaltystatus='+loyaltyStatus);
                cmp.set("v.isLoyaltyApplicable",loyaltyStatus);
                console.log('*****'+cmp.get("v.isLoyaltyApplicable"));
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
        
        $A.enqueueAction(actionMergeLoyalty);
	},
    
    
    handleMergeLoyalty: function(cmp, event, helper) {
      console.log('inside handleMergeLoyalty');
      var currentRecordId =  cmp.get("v.recordId");  
      var workspaceAPI = cmp.find("workspace");
        console.log('*****workspaceAPI = '+workspaceAPI);
        workspaceAPI.openSubtab({
            url: '/flow/Merge_LoyaltyId?curCase2='+currentRecordId+'&retURL=/'+currentRecordId,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
            console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
                console.log(error);
        });
      
    },
})