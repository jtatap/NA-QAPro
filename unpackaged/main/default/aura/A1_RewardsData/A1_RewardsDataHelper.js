({
	showToast : function(cmp, event,displayType,displayTitle,errorMessage) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : displayType,
            "title": displayTitle,
            "message": errorMessage
        });
        toastEvent.fire();
    }
})