({
    doInit : function(component, event, helper) {
        console.log('doInit toggleCloseCaseTab');
        helper.init(component, event, helper);
    },
    recordUpdated: function(component, event, helper) {
        console.log('recordUpdated');
        var changeType = event.getParams().changeType;
        var error = String($A.get("$Label.c.Error1"));
        var loaded = String($A.get("$Label.c.Loaded"));
        var removed = String($A.get("$Label.c.Removed"));
        var changed = String($A.get("$Label.c.Changed"));

        if (changeType === error) { /* handle error; do this first! */
            console.log('ERROR');
        } else if (changeType === loaded) { /* handle record load */
            console.log('LOADED');
        } else if (changeType === removed) { /* handle record removal */
            console.log('REMOVED');
        } else if (changeType === changed) { /* handle record change */
            console.log('CHANGED');
            $A.get('e.force:refreshView').fire();
        }
    }
})