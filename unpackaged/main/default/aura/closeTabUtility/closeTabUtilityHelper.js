/**
 * Created by bryananderson on 11/21/19.
 */

({
    tabClosed: function (component, event, helper, recId) {
        var action = component.get("c.doCaseRouting");
        var success = String($A.get("$Label.c.Success1"));
        var error = String($A.get("$Label.c.Error1"));
        console.log('HELPER tabClosed recordId: ' + recId);
        action.setParams({caseId: recId});
        action.setCallback(this, $A.getCallback(function (resp) {
                console.log('state' + resp);
                var state = resp.getState();
                if (state === success) {
                    var result = resp.getReturnValue();
                    console.log(result);
                } else if (state === error) {
                    var errors = resp.getError();
                    console.log(errors);
                }
            }
        ));
        $A.enqueueAction(action);
    }
});