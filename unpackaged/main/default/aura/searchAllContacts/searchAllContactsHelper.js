({
    SearchHelper: function(component, event) {
        // show spinner message
         component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchContact");
        var error = String($A.get("$Label.c.Error1"));
        var success = String($A.get("$Label.c.Success1"));
        var incomplete = String($A.get("$Label.c.Incomplete"));
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
           // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === success) {
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);
                
                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse); 
                
            }else if (state === incomplete) {
                alert('Response is Incompleted');
            }else if (state === error) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
     handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
		 var finalData=cmp.get("v.searchResult"); 
        var cloneData = finalData.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.searchResult', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    },
})