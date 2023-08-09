({
    init: function (component, event, helper) {
        var action = component.get("c.getDisableStatus");
        var error = String($A.get("$Label.c.Error1"));
        var success = String($A.get("$Label.c.Success1"));
        
        action.setParams({caseId: component.get("v.recordId")});
        action.setCallback(this, $A.getCallback(function (resp) {
                console.log('state' + resp);
                var state = resp.getState();
                if (state === success) {
                    var result = resp.getReturnValue();
                    var workspaceAPI = component.find("workspace");
                    if (result === true) {
                        var appEvent = $A.get("e.c:getRecordIdEvent");
                        appEvent.setParams({
                            "recordId" : component.get("v.recordId")
                        });
                        appEvent.fire();


                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            
                            component.set('v.isDisabled', true);
                            
                        })
                            .catch(function (error) {
                                console.log(error);
                            });
                    } else {
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                           
                            component.set('v.isDisabled', false);
                            
                        })
                        .catch(function (error) {
                            console.log(error);
                        });

                    }
                } else if (state === error) {
                    var errors = resp.getError();
                    console.log(errors);
                }
            }
        ));
        $A.enqueueAction(action);
    }
})