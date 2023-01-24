({
    init: function (component, event, helper) {
        var action = component.get("c.getDisableStatus");
        action.setParams({caseId: component.get("v.recordId")});
        action.setCallback(this, $A.getCallback(function (resp) {
                console.log('state' + resp);
                var state = resp.getState();
                if (state === "SUCCESS") {
                    var result = resp.getReturnValue();
                    var workspaceAPI = component.find("workspace");
                    if (result === true) {
                        var appEvent = $A.get("e.c:getRecordIdEvent");
                        appEvent.setParams({
                            "recordId" : component.get("v.recordId")
                        });
                        appEvent.fire();


                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            //var focusedTabId = response.tabId;
                            component.set('v.isDisabled', true);
                            /*workspaceAPI.disableTabClose({
                                tabId: focusedTabId,
                                disabled: true,
                                closeable: false
                            })
                            .then(function (tabInfo) {
                                console.log(tabInfo);
                            })
                            .catch(function (error) {
                                console.log(error);
                            });*/
                        })
                            .catch(function (error) {
                                console.log(error);
                            });
                    } else {
                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                            //var focusedTabId = response.tabId;
                            component.set('v.isDisabled', false);
                            /*workspaceAPI.disableTabClose({
                                tabId: focusedTabId,
                                disabled: false,
                                closeable: true
                            })
                            .then(function (tabInfo) {
                                console.log(tabInfo);
                            })
                            .catch(function (error) {
                                console.log(error);
                            });*/
                        })
                        .catch(function (error) {
                            console.log(error);
                        });

                    }
                } else if (state === "ERROR") {
                    var errors = resp.getError();
                    console.log(errors);
                }
            }
        ));
        $A.enqueueAction(action);
    }
})