({
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField,mapAttrName) {
        // call the server side function 
      
        
        var success = String($A.get("$Label.c.Success1"));
        var action = component.get("c.getDependentPicklist");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == success) {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
               // once set #StoreResponse to depnedentFieldMap attribute 
                component.set(mapAttrName,StoreResponse);
                
                if(mapAttrName == 'v.depnedentFieldMap'){

                    // create a empty array for store map keys(@@--->which is controller picklist values) 
                    var listOfkeys = []; // for store all map keys (controller picklist values)
                    var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                    
                    // play a for loop on Return map 
                    // and fill the all map key on listOfkeys variable.
                    for (var singlekey in StoreResponse) {
                        listOfkeys.push(singlekey);
                    }
                    
                    //set the controller field value for lightning:select
                    if (listOfkeys != undefined && listOfkeys.length > 0) {
                        ControllerField.push('--- None ---');
                    }
                    
                    for (var i = 0; i < listOfkeys.length; i++) {
                        ControllerField.push(listOfkeys[i]);
                    }  
                    // set the ControllerField variable values to country(controller picklist field)
                    component.set("v.listControllingValues", ControllerField);
                    
                }
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields,lstAttrName) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set(lstAttrName, dependentFields);
        
    },
    
   
      
})