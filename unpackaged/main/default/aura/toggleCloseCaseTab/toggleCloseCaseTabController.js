({
    doInit : function(component, event, helper) {
        console.log('doInit toggleCloseCaseTab');
        helper.init(component, event, helper);
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
        }
    }
})