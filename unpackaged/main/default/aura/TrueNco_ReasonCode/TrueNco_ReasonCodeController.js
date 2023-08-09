({
	doInit : function(component, event, helper) { 
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var subDependingFieldAPI = component.get("v.subDependingFieldAPI"); 
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI, "v.depnedentFieldMap");
        helper.fetchPicklistValues(component,objDetails,dependingFieldAPI, subDependingFieldAPI, "v.subDepnedentFieldMap");
        
        
    },
    
      handleClick: function (cmp, event, helper) {
      var radioGrpValue = cmp.get("v.value");    
      cmp.set("v.grandParentValue" , radioGrpValue);
      
      var controllerValueKey=cmp.get("v.grandParentValue");
      var depnedentFieldMap = cmp.get("v.depnedentFieldMap");
       if (controllerValueKey != '--- None ---') {
           var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
           
           if(ListOfDependentFields.length > 0){
               cmp.set("v.bDisabledDependentFld" , false);  
                
                helper.fetchDepValues(cmp, ListOfDependentFields,"v.listDependingValues");    
            }else{
                cmp.set("v.bDisabledDependentFld" , true); 
                cmp.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            cmp.set("v.listDependingValues", ['--- None ---']);
            cmp.set("v.bDisabledDependentFld" , true);
        }
          cmp.set("v.bDisabledSubDependentFld" , true);
           cmp.set("v.isclicked", true);
          if(controllerValueKey != 'Product'){
                     cmp.set("v.isSkunumber",false);
                }
         if(controllerValueKey != 'Product'){
                     cmp.set("v.isPurchased",false);
                }
      },
    
    onControllerFieldChange : function(component, event, helper) {  
        var controllerValueKey = event.getSource().get("v.value"); // get selected sub controller field value
        var depnedentFieldMap = component.get("v.subDepnedentFieldMap");
        component.set("v.parentValue" , controllerValueKey);
        component.set("v.ischild" ,true);
        
          if (controllerValueKey != '--- None ---') {
              component.set("v.ischild" ,true);
             var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledSubDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,"v.listSubDependingValues");
                
               }else{
                component.set("v.bDisabledSubDependentFld" , true); 
                component.set("v.listSubDependingValues", ['']);
               }  
           } else {
                component.set("v.listSubDependingValues", ['']);
               
               component.set("v.bDisabledSubDependentFld" , true);
            }
        
               
     
          },
     onSubControllerFieldChange : function(component, event, helper) {
         var childFieldValue = event.getSource().get("v.value");
         var grandParentFieldValue = component.get("v.grandParentValue"); 
         var parentFieldValue = component.get("v.parentValue");    
         if(grandParentFieldValue ==='Product' && parentFieldValue === "Defective" && childFieldValue ==="Manufacturing Issue"){
             component.set("v.isSkunumber",true);
             
            }
         else{
                    component.set("v.isSkunumber",false);
        }
         if(grandParentFieldValue ==='Product' && parentFieldValue === "Defective" ){
             component.set("v.isPurchased",true);
             
            }
         else{
                    component.set("v.isPurchased",false);
        }
         
     },
    
    
     handleSubmit: function (cmp, event,helper) {
         var parentField = cmp.find("parentField").get("v.value");
         var childField = cmp.find("childField").get("v.value");
         var grandParentField=cmp.get("v.grandParentValue");
         debugger;
        if(parentField === 'Defective'){
            var action1 = cmp.get("c.trueNcoUpdateCase");
            action1.setParams({"recordId":cmp.get("v.recordId"),
                            "grandParent":cmp.get("v.grandParentValue"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "placeOfPurchase":cmp.find("placeOfPurchase").get("v.value"),
                            "skuNumber" :cmp.get("v.skunumberatt"),
                            "channel":cmp.get("v.channelatt")
                              }); 
         }
         
         if(parentField === 'Defective' && childField === 'Manufacturing Issue'){
             
           var action1 = cmp.get("c.trueNcoUpdateCase");
           action1.setParams({"recordId":cmp.get("v.recordId"),
                            "grandParent":cmp.get("v.grandParentValue"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "placeOfPurchase":cmp.find("placeOfPurchase").get("v.value"),
                             "skuNumber":cmp.find("skuNumber").get("v.value"),
                             "channel":cmp.find("channel").get("v.value")
                              });
         
             
             
         }
         if(parentField != 'Defective'){
         var action1 = cmp.get("c.trueNcoUpdateCase");
         action1.setParams({"recordId":cmp.get("v.recordId"),
                            "grandParent":cmp.get("v.grandParentValue"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "placeOfPurchase":cmp.get("v.placeofPurchaseatt"),
                            "skuNumber" :cmp.get("v.skunumberatt"),
                             "channel":cmp.get("v.channelatt")
                             });
         
          }
         action1.setCallback(this, function(response){
         	var status = response.getState();
             var error = String($A.get("$Label.c.Error1"));
             var success = String($A.get("$Label.c.Success1"));
          
              if(status === success){
                   
                 
              var workspaceAPI = cmp.find("workspace");
               workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.refreshTab({
                                tabId: focusedTabId,
                                includeAllSubtabs: false,
                                "isEdit":true
                                
                    
                });
            })
            .catch(function(error) {
                console.log(error);
            });
          
                  
                 }
             else if(status === error){
                
             }
            
         });
        $A.enqueueAction(action1);
         
     },
    
    isCancel: function(cmp, event, helper) {
          cmp.set("v.isEdit",true); 
         
     }, 
    
     handleEdited: function(component, event, helper) {
        component.set("v.isEdit",false);
    },
    
    isRefreshed: function(cmp, event, helper) {
         cmp.set("v.isEdit",true); 
       
     },
    recordLoaded: function(cmp, event, helper) {
       var eventParams = event.getParams();
       var error = String($A.get("$Label.c.Error1"));
        var loaded = String($A.get("$Label.c.Loaded"));
        var removed = String($A.get("$Label.c.Removed"));
        var changed = String($A.get("$Label.c.Changed"));
        if(eventParams.changeType === changed) {
        } else if(eventParams.changeType === loaded) {
            // record is loaded in the cache
        } else if(eventParams.changeType === removed) {
            //record is deleted.
        } else if(eventParams.changeType === error) {
            // there’s an error while loading, saving, or deleting the record
        } 
    },
      
    
})