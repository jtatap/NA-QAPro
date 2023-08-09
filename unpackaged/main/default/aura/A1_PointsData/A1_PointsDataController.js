({
	doInit : function(cmp, event, helper) {
        
        var getRecord = cmp.get("v.recordId");
        var ifCase = getRecord.startsWith("500");
        var success = String($A.get("$Label.c.Success1"));
        var incomplete = String($A.get("$Label.c.Incomplete"));
        var error = String($A.get("$Label.c.Error1"));
        cmp.set("v.isCaseRecord",ifCase);
        
        //PendingPointCheckStarts
        var actionPendingPoints = cmp.get("c.checkPendingPointsStatus");
        actionPendingPoints.setParams({ recordId : cmp.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        actionPendingPoints.setCallback(this, function(response) {
            var state = response.getState();
            if (state === success) {
                
                var getWrapperObject = response.getReturnValue();
                if(getWrapperObject.isPendingPointAdjustment==false){
                    cmp.set("v.pendingPointAdjustment",true);
                    
                }
                cmp.set("v.isEnableRewardsButton",getWrapperObject.isEnableRewardsButton);
                
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
		//PendingPointCheckEnds
        
        
        var action = cmp.get("c.getPoints");
        action.setParams({ recordIds : cmp.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === success) {
                var currentPointBalance;
                var pointList = response.getReturnValue();
                //check if type = Category= Customer Summary
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    if (pointList[i].Category == "Customer Summary") {
                        currentPointBalance = pointList[i].currentPointBalance;
                        console.log('***CPB = '+currentPointBalance);
                        cmp.set("v.currentPointBalance",currentPointBalance);
                    }
                    console.log('Record '+i+' = '+pointList[i].IssueDate);
    			}
                
                pointList.sort(function(a,b){
                    // Turn your strings into dates, and then subtract them
                    // to get a value that is either negative, positive, or zero.
                    return new Date(b.IssueDate) - new Date(a.IssueDate);
                });
                 for (var i = 0; i < pointList.length; i++) {
                	 console.log('Final Record '+i+' = '+pointList[i].IssueDate);
                 
                 }
                
                 cmp.set("v.pointWrapper",pointList);
                
                cmp.set("v.numRecords",pointList.length);
                
                /* fire application event */
                var appEvent = $A.get("e.c:A1_PointEvent"); 
                //Set event attribute value
                appEvent.setParams({"pointWrapperFromEvent" : pointList}); 
                appEvent.fire(); 
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

        // $A.enqueueAction adds the server-side action to the queue.
        if(cmp.get("v.isCaseRecord")){
       	$A.enqueueAction(actionPendingPoints);
        }
		$A.enqueueAction(action);
		
	},
    
    handlePointAdjustment: function(cmp, event, helper) {
      
        
      var currentRecordId =  cmp.get("v.recordId");  
      var workspaceAPI = cmp.find("workspace");
        workspaceAPI.openSubtab({
            url: '/flow/CSR_Loyalty_Points_Adjustment?curCase2='+currentRecordId+'&retURL=/'+currentRecordId,
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

    
    handleRewardAdjustment :  function(cmp, event, helper) {
      
      var currentRecordId =  cmp.get("v.recordId");  
      var workspaceAPI = cmp.find("workspace");
        workspaceAPI.openSubtab({
            url: '/flow/CSR_Loyalty_Rewards_Adjustments?curCase2='+currentRecordId+'&retURL=/'+currentRecordId,
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
    
    
    
    handleClick: function(cmp, event, helper) {
        
        var idx = event.target.id;
        var getPointWrapper = cmp.get("v.pointWrapper")[idx];
        var success = String($A.get("$Label.c.Success1"));
        
        
        $A.createComponent("c:A1_PointDetails",
                           {
                               "pointWrapper" : getPointWrapper,
                               "indexRow" : idx    
                           },
                           function(content, status) {
                               if (status === success) {
                                   var modalBody = content;
                                   cmp.find('overlayLib').showCustomModal({
                                       body: modalBody, 
                                       showCloseButton: true,
                                      
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   }).then(function(overlay){
                                       console.log("Overlay is made");
                                   });
                               }
                           });
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