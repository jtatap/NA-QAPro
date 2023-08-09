/**
 * Created by apoorvrajput on 10/13/20.
 */

({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var success = String($A.get("$Label.c.Success1"));
        var error = String($A.get("$Label.c.Error1"));
		var action = component.get("c.getRelatedCase");
        action.setParams({
            "transId": recordId
        });
        action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === success) {
            var result = response.getReturnValue();
            console.log('result>>'+result);
            var workspaceAPI = component.find("workspace");
            if(result.recentCaseId !== '' && result.recentCaseId !== null && result.recentCaseId !== undefined){
                //call workspace api to open sub tab.
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedPrimaryTabId = response.parentTabId;
                    workspaceAPI.openSubtab({parentTabId: focusedPrimaryTabId,
                                             url: '/lightning/r/Case/'+result.recentCaseId+'/view',
                                             focus: false});
               })
                .catch(function(error) {
                    console.log('error>>>'+error);
                });
            }
            if(result.recentContactId !== '' && result.recentContactId !== null && result.recentContactId !== undefined) {
                //call workspace api to open sub tab.
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedPrimaryTabId = response.parentTabId;
                    workspaceAPI.openSubtab({parentTabId: focusedPrimaryTabId,
                                             url: '/lightning/r/Contact/'+result.recentContactId+'/view',
                                             focus: false});
               })
                .catch(function(error) {
                    console.log('error>>>'+error);
                });
            }
        } else if (state === error) {
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
	}
})