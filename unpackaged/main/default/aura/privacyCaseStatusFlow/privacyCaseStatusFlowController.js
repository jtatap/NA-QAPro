/**
 * Created by bryananderson on 10/21/19.
 */

({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("privacyCaseStatus");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Privacy_Case_Status_Screens", inputVariables);
    },
    handleStatusChange : function (component, event) {
        console.log('event.getParam("status")===' + event.getParam("status"));
         var error = String($A.get("$Label.c.Error1"));
        var finished = String($A.get("$Label.c.Finished"));

        if(event.getParam("status") === finished) {
            console.log('handleStatusChange FINISHED');
            $A.get('e.force:refreshView').fire();
        } else if(event.getParam("status") === error) {
            console.log('handleStatusChange ERROR');
        }
    },
    recordUpdated: function(component, event, helper) {
        console.log('recordUpdated');
        var changeType = event.getParams().changeType;
        var error = String($A.get("$Label.c.Error1"));
        var loaded = String($A.get("$Label.c.Loaded"));
        var removed = String($A.get("$Label.c.Removed"));
        var changed = String($A.get("$Label.c.Changed"));
        var success = String($A.get("$Label.c.Success1"));

        if (changeType === error) { /* handle error; do this first! */
            console.log('ERROR');
        } else if (changeType === loaded) { /* handle record load */
            console.log('LOADED');
        } else if (changeType === removed) { /* handle record removal */
            console.log('REMOVED');
        } else if (changeType === changed) { /* handle record change */
            console.log('CHANGED');
            $A.get('e.force:refreshView').fire();

            var privacyFlow = component.find("privacyCaseStatus");

            privacyFlow.destroy();
            $A.createComponent(
                "lightning:flow",{
                    "aura:id" : "privacyCaseStatus",
                    "onstatuschange" : component.getReference("c.handleStatusChange")
                },
                function(privacyFlow, status, errorMessage){
                    console.log('STATUS=== ' + status + ' - ' + errorMessage);
                    if (status === success) {
                        // Finding the div by aura:id and pushing newly created component into it.
                        var outerDiv = component.find('outerDiv').get('v.body');
                        outerDiv.push(privacyFlow);
                        component.find('outerDiv').set('v.body', outerDiv);

                        var inputVariables = [
                            {
                                name : "recordId",
                                type : "String",
                                value : component.get("v.recordId")
                            }
                        ];
                        // In that component, start your flow. Reference the flow's API Name.
                        privacyFlow.startFlow("Privacy_Case_Status_Screens", inputVariables);
                    }
                }
            );
        }
    }
})