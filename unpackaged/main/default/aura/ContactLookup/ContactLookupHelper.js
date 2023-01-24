({
    processResults : function(results, returnFields, searchText) {
         console.log('searchText'+searchText);
        var regEx = null;
        if (searchText != null && searchText.length> 0) {
            regEx = new RegExp(searchText, 'gi');
        }
        
        for (var i = 0; i < results.length; i++) {
            
            results[i]['Field0'] = results[i][returnFields[0]].replace(regEx,'<mark>$&</mark>');
            
            for(var j = 1; j < returnFields.length; j++){
                var fieldValue = results[i][returnFields[j]];
                if (fieldValue) {
                    results[i]['Field1'] = (results[i]['Field1'] || '') + ' • ' + fieldValue;
                }
            }
            if (results[i]['Field1']) {
                results[i]['Field1'] = results[i]['Field1'].substring(3).replace(regEx,'<mark>$&</mark>');
            }
        }
         console.log('results'+results);
        return results;
    },
     SearchHelper: function(component, event) {
        // show spinner message
        alert('searchKeyWord***'+searchKeyWord);
         component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchContact");
        action.setParams({
            'searchKeyWord': component.get("v.searchableKeyword")
        });
           console.log('searchKeyWord***'+searchKeyWord);
        action.setCallback(this, function(response) {
           // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
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
                component.set("v.searchableResult", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
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
     SubmitHelper: function(component, event) {
         console.log('Entered into the after helper>>'+ component.get('v.selectedId'));
         var contName=component.get('v.selectedId');
        // component.set("v.selectedName", contName);
          component.set("v.isOpen", false);
     }
})