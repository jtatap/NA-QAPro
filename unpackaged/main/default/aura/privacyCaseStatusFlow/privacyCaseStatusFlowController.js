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
        if(event.getParam("status") === "FINISHED") {
            console.log('handleStatusChange FINISHED');
            $A.get('e.force:refreshView').fire();
        } else if(event.getParam("status") === "ERROR") {
            console.log('handleStatusChange ERROR');
        }
    },
    recordUpdated: function(component, event, helper) {
        console.log('recordUpdated');
        var changeType = event.getParams().changeType;

        if (changeType === "ERROR") { /* handle error; do this first! */
            console.log('ERROR');
        } else if (changeType === "LOADED") { /* handle record load */
            console.log('LOADED');
        } else if (changeType === "REMOVED") { /* handle record removal */
            console.log('REMOVED');
        } else if (changeType === "CHANGED") { /* handle record change */
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
                    if (status === "SUCCESS") {
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