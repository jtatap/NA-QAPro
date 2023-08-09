({
 getCases: function(component) {
    var action = component.get("c.getCases");
    var success = String($A.get("$Label.c.Success1"));
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state === success) {
            component.set("v.cases", response.getReturnValue());
        }
    });
    $A.enqueueAction(action);  },


  createCase: function(component, event) {
       console.log('Inside** Create Case');
    this.upsertCase(component, event, function(a) {
        var cases = component.get("v.cases");
        cases.push(a.getReturnValue());
        component.set("v.cases", cases);
      });
},
    
    updateSelectedContact: function(component, selectedContact) {

		var selectedContact = component.get("v.selectedContact");
		
		var action = component.get("c.getLstContact");
		action.setParams({
			"contact" : selectedContact
		});       
		action.setCallback(this,function(a){
			component.set("v.object",a.getReturnValue());
		});       
		$A.enqueueAction(action);

	},

upsertCase : function(component, event, callback) {
     console.log('Inside** upsertCase');
    var action = component.get("c.saveCase");
    action.setParams({ 
        "case": event
    });
    if (callback) {
      action.setCallback(this, callback);
    }
    $A.enqueueAction(action);

},})