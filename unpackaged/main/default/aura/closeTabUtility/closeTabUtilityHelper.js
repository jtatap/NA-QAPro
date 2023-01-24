/**
 * Created by bryananderson on 11/21/19.
 */

({
    tabClosed: function (component, event, helper, recId) {
        var action = component.get("c.doCaseRouting");
        console.log('HELPER tabClosed recordId: ' + recId);
        action.setParams({caseId: recId});
        action.setCallback(this, $A.getCallback(function (resp) {
                console.log('state' + resp);
                var state = resp.getState();
                if (state === "SUCCESS") {
                    var result = resp.getReturnValue();
                    console.log(result);
                } else if (state === "ERROR") {
                    var errors = resp.getError();
                    console.log(errors);
                }
            }
        ));
        $A.enqueueAction(action);
    }
});