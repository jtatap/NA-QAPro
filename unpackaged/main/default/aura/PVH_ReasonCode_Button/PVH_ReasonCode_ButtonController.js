({
    doInit : function(component, event, helper) { 
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var subDependingFieldAPI = component.get("v.subDependingFieldAPI");
        var productCatFieldAPI=component.get("v.productCatFieldAPI");
        var productSubCatFieldAPI=component.get("v.productSubCatFieldAPI");
        var thirdPartyVendorAPI=component.get("v.thirdPartyVendorAPI");
        //var productCategoryFieldAPI = component.get("v.productCategoryFieldAPI");
        
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI, "v.depnedentFieldMap");
        
        // 2nd and 3rd picklist 
        helper.fetchPicklistValues(component,objDetails,dependingFieldAPI, subDependingFieldAPI, "v.subDepnedentFieldMap");
        //4th picklist
        helper.fetchPicklistValues(component,objDetails,productCatFieldAPI, productSubCatFieldAPI, "v.producsubtCategoryValueMap");
        helper.fetchPicklistValues(component,objDetails,productSubCatFieldAPI, thirdPartyVendorAPI, "v.thirdPartyValueMap");
      

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
            cmp.set("v.listSubDependingValues", ['']);
            cmp.set("v.isclicked", true);
         
          if(event.getSource().get("v.label")!="Service"){
                    cmp.set("v.isRequired",false);
                    cmp.set("v.isRequired1",false);
                }
        if(event.getSource().get("v.label")!="Product"){
             cmp.set("v.isRequiredManufacturer",false);
             cmp.set("v.isRequiredProduct",false);
             cmp.set("v.isProCatSubSelected",false);
             cmp.set("v.isProCatSelecting",false);
        }
         if(event.getSource().get("v.label")!="Loyalty"){
              cmp.set("v.isAccInfoReason",false);
             
        }
        
        
    },
    
    

  
    
    onSubControllerFieldChange : function(component, event, helper) {     
         var controllerValueKey = event.getSource().get("v.value"); // get selected sub controller field value
         var depnedentFieldMap = component.get("v.subDepnedentFieldMap");
        
         
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
        
           
            
              if((controllerValueKey == "Care Instructions") || 
                (controllerValueKey == "Counterfeit Merchandise") ||
                (controllerValueKey == "Defective Merchandise") ||
                (controllerValueKey == "Product Inquiry") ||
                (controllerValueKey == "Product Repair") ||
                (controllerValueKey == "Sizing Feedback") ||
                (controllerValueKey == "Sizing Question")
               ) {
               
                component.set("v.isRequiredProduct",true);
                helper.fetchPickListVal(component, 'Reason_Code_Product_Category__c', 'productCategory');
                 
                }
            
           
           if(controllerValueKey == "Defective Merchandise"){
               
                component.set("v.isRequiredManufacturer",true);
                helper.fetchPickListVal(component, 'Reason_Code_Manufacturers__c', 'manufacturer');
            } 
            else {
                component.set("v.isRequiredManufacturer",false);
            }
            if(controllerValueKey == "Good Service") {
                component.set("v.isRequired",true);
            }
            else if(controllerValueKey == "Poor Service"){
                 component.set("v.isRequired1",true);
            }
            else if(controllerValueKey == "Other" ){
                component.set("v.isRequired",false);
                component.set("v.isRequired1",false);
            }
           if(controllerValueKey == "Edit Account Information"){
                  component.set("v.isAccInfoReason",true);
              }
            else{
               component.set("v.isAccInfoReason",false);
            }
        
        
               
                     
        
          
        
        
        
           
           
        },
    
    
    
    onSubDependentFieldChange: function (cmp, event,helper) {
         var controllerValueKey = event.getSource().get("v.value");
            if(controllerValueKey == "Update Account Info Reason"){
                    cmp.set("v.isAccInfoReason",true);
        }
        else
        {
            cmp.set("v.isAccInfoReason",false);
        }
        
    },
    
    onProCatChange: function (component, event,helper) {
         var proCatValue = event.getSource().get("v.value");
         component.set("v.productCategoryValue",proCatValue);
         
          var depnedentFieldMap = component.get("v.producsubtCategoryValueMap");
       
          if(proCatValue != '--- None ---' && ( proCatValue == 'Accessories' || 
			 proCatValue == 'Footwear' || proCatValue == 'Home Products' 	 || 
		     proCatValue == 'Outerwear' ||  proCatValue == 'Swimwear' ||
		     proCatValue == 'Underwear'  )
            ){
              component.set("v.isProCatSelecting",true);
              var ListOfProSubCatFields = depnedentFieldMap[proCatValue];
            if(ListOfProSubCatFields.length > 0){
                
               
                helper.fetchDepValues(component, ListOfProSubCatFields,"v.listProSubCatValues");
                
            }else{
                component.set("v.listProSubCatValues", ['--- None ---']);	
            } 
        }else {
           
            component.set("v.listProSubCatValues", ['--- None ---']);
            component.set("v.isProCatSelecting",false);
          }
        if(proCatValue != 'Swimwear'){
             component.set("v.isProCatSubSelected",false);
        }
       
        
    },
    onProSubCatChange: function (component, event,helper) {
        var proSubCatValue = event.getSource().get("v.value");
           component.set("v.producsubtCategoryValue",proSubCatValue);
           var depnedentFieldMap = component.get("v.thirdPartyValueMap");
       
          if(proSubCatValue !='--- None ---' && (proSubCatValue =='Elite/LZR Competition' || proSubCatValue =='General Swimwear')){
            component.set("v.isProCatSubSelected",true);
          	var ListOfThirdPartyVenFields = depnedentFieldMap[proSubCatValue];
            if(ListOfThirdPartyVenFields.length > 0){
              helper.fetchDepValues(component, ListOfThirdPartyVenFields,"v.listthirdPartyVendorValues");
                
            }else{
                component.set("v.listthirdPartyVendorValues", ['---None---']);	
            } 
        }else {
            component.set("v.listthirdPartyVendorValues", ['---None---']);
            
          }
        
    },
    
    onManufacturerChange: function (cmp, event,helper) {
        var manufacturerValue = event.getSource().get("v.value");
         cmp.set("v.manufacturerValue",manufacturerValue);
        
    },
    onthirdPartyChange: function (cmp, event,helper) {
        var thirdParrtyValue = event.getSource().get("v.value");
         cmp.set("v.thirdParrtyValue",thirdParrtyValue);
        
    },
    
     handleSubmit: function (cmp, event,helper) {
        
       var id = cmp.get("v.recordId") ;
        var myText = cmp.get("v.myText");
       
         var parentField = cmp.find("parentField").get("v.value");
         var childField = cmp.find("childField").get("v.value");
         var grandParentField=cmp.get("v.grandParentValue");
         var prodCatValue=cmp.get("v.productCategoryValue");
         var prosubCatValue= cmp.get("v.producsubtCategoryValue");
      
       if((parentField === 'Good Service') || (parentField === 'Poor Service')){
          var regExpNumberformat=/^[0-9]+$/;
           
            cmp.find('storeNumber').showHelpMessageIfInvalid();
            cmp.find('storeNumber').focus();
            cmp.find('districtNumber').showHelpMessageIfInvalid();
            cmp.find('districtNumber').focus();
           
          var action4 = cmp.get("c.updateCase");
          action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.find("storeNumber").get("v.value"),
                            "districtNumber":cmp.find("districtNumber").get("v.value"),
                             "manufacturer":cmp.get("v.manufactureratt"),
                             "productSubCategory":cmp.get("v.producsubtCategoryatt"),
                             "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                             "productCategory":cmp.get("v.productCategoryatt"),
                             "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             }); 
           
        } 
         if(parentField === 'Poor Service'){
           var today = new Date();
          
             
            cmp.find('dateofServiceIssue').showHelpMessageIfInvalid();
            cmp.find('dateofServiceIssue').focus();
             
           var action4 = cmp.get("c.updateCase");
          action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.find("dateofServiceIssue").get("v.value"),
                            "storeNumber":cmp.find("storeNumber").get("v.value"),
                            "districtNumber":cmp.find("districtNumber").get("v.value"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "manufacturer":cmp.get("v.manufactureratt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryatt"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "productCategory":cmp.get("v.productCategoryatt"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             }); 
           
            }
         
          if((parentField === 'Defective Merchandise') && 
            (prodCatValue != '--- None ---' && prosubCatValue === '--- None ---') ){
            
             var action4 = cmp.get("c.updateCase");
             action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryatt"),  
                            "manufacturer":cmp.get("v.manufacturerValue"),
                            "productCategory":cmp.get("v.productCategoryValue"),
                            "skuNumber":cmp.find("skuNumber").get("v.value"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });
             
             
         }
         if((parentField === 'Defective Merchandise') &&
            (prodCatValue != '--- None ---' && prosubCatValue != '--- None ---') ){
            
             var action4 = cmp.get("c.updateCase");
             action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryValue"),  
                            "manufacturer":cmp.get("v.manufacturerValue"),
                            "productCategory":cmp.get("v.productCategoryValue"),
                            "skuNumber":cmp.find("skuNumber").get("v.value"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });
             
             
         }
         if(parentField === 'Defective Merchandise'){
             var prodCatValue=cmp.get("v.productCategoryValue");
             var prosubCatValue= cmp.get("v.producsubtCategoryValue");
              if(prodCatValue === 'Swimwear'){
                  if(prosubCatValue === 'Elite/LZR Competition' || prosubCatValue === 'General Swimwear'){
                     
                      
                   cmp.find('thirdPartyVendors').showHelpMessageIfInvalid();
                   cmp.find('thirdPartyVendors').focus();   
                }
             }
                  
             var action4 = cmp.get("c.updateCase");
             action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "thirdPartyVendor":cmp.get("v.thirdParrtyValue"),
                            "productSubCategory":cmp.get("v.producsubtCategoryValue"),  
                            "manufacturer":cmp.get("v.manufacturerValue"),
                            "productCategory":cmp.get("v.productCategoryValue"),
                            "skuNumber":cmp.find("skuNumber").get("v.value"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });
             
             
         }
         
           if(((parentField === 'Care Instructions') || 
                (parentField === 'Counterfeit Merchandise') ||
                (parentField === 'Product Inquiry') ||
                (parentField === 'Product Repair') ||
                (parentField === 'Sizing Feedback') ||
                (parentField === 'Sizing Question')) &&
                (prodCatValue != '--- None ---' && prosubCatValue != '--- None ---')
             ){      
                
               
           
          var action4 = cmp.get("c.updateCase");
          action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "manufacturer":cmp.get("v.manufactureratt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryValue"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "productCategory":cmp.get("v.productCategoryValue"),
                            "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });   
             } 
          if(((parentField === 'Care Instructions') || 
                (parentField === 'Counterfeit Merchandise') ||
                (parentField === 'Product Inquiry') ||
                (parentField === 'Product Repair') ||
                (parentField === 'Sizing Feedback') ||
                (parentField === 'Sizing Question')) &&
                (prodCatValue != '--- None ---' && prosubCatValue === '--- None ---')
              ){      
              
             
          var action4 = cmp.get("c.updateCase");
          action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "manufacturer":cmp.get("v.manufactureratt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryatt"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "productCategory":cmp.get("v.productCategoryValue"),
                            "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });   
             }
          if(((parentField === 'Care Instructions') || 
                (parentField === 'Counterfeit Merchandise') ||
                (parentField === 'Product Inquiry') ||
                (parentField === 'Product Repair') ||
                (parentField === 'Sizing Feedback') ||
                (parentField === 'Sizing Question')) &&
                (prodCatValue === 'Swimwear' && (prosubCatValue === 'Elite/LZR Competition' || prosubCatValue === 'General Swimwear'))
              ){  
             
           
          var action4 = cmp.get("c.updateCase");
          action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                             "thirdPartyVendor":cmp.get("v.thirdParrtyValue"),
                            "manufacturer":cmp.get("v.manufactureratt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryValue"),
                             "productCategory":cmp.get("v.productCategoryValue"),
                            "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });   
             } 
                  
                  
         if(parentField === 'Edit Account Information'){
           
           
             cmp.find('updateAccInfoReason').showHelpMessageIfInvalid();
             cmp.find('updateAccInfoReason').focus(); 
             
           var action4 = cmp.get("c.updateCase");
           action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "manufacturer":cmp.get("v.manufactureratt"),
                            "productCategory":cmp.get("v.productCategoryatt"),
                            "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryatt"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.find("updateAccInfoReason").get("v.value"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             }); 
               }
         
          
       if((parentField != 'Good Service') && 
          (parentField != 'Poor Service') && 
          (parentField != 'Defective Merchandise') &&
          (parentField != 'Care Instructions') && 
          (parentField != 'Counterfeit Merchandise') &&
          (parentField != 'Product Inquiry') &&
          (parentField != 'Product Repair') &&
          (parentField != 'Sizing Feedback') &&
          (parentField != 'Sizing Question') &&
          (parentField != 'Edit Account Information') 
          
         ){
          var action4 = cmp.get("c.updateCase");
          action4.setParams({"recordId":cmp.get("v.recordId"),
                            "dateofServiceIssue":cmp.get("v.dateofServiceIssueatt"),
                            "manufacturer":cmp.get("v.manufactureratt"),
                            "productCategory":cmp.get("v.productCategoryatt"),
                            "productSubCategory":cmp.get("v.producsubtCategoryatt"),
                            "storeNumber":cmp.get("v.storeNumberatt"),
                            "thirdPartyVendor":cmp.get("v.thirdPartyVendoratt"),
                            "skuNumber":cmp.get("v.skuStyleNumberatt"),
                            "districtNumber":cmp.get("v.districtNumberatt"),
                            "updateAccountInfoReason":cmp.get("v.updateAccountInfoReasonatt"),
                            "parentField":cmp.find("parentField").get("v.value"),
                            "childField":cmp.find("childField").get("v.value"),
                            "grandParent":cmp.get("v.grandParentValue")
                             });
       }
               
        action4.setCallback(this, function(response){
         	var status = response.getState();
          
              if(status === "SUCCESS"){
                   
                
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
             else if(status === "ERROR"){
                
             }
            
         });
        $A.enqueueAction(action4);
       
     }, 

    
      handleClearErrors: function(cmp, event, helper) {
      
    },
     isRefreshed: function(cmp, event, helper) {
         cmp.set("v.isEdit",true); 
       
     }, 
        
    isCancel: function(cmp, event, helper) {
          cmp.set("v.isEdit",true); 
          
     }, 
    
    handleEdited: function(component, event, helper) {
        component.set("v.isEdit",false);
    },
    recordLoaded: function(cmp, event, helper) {
        
        
      var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
           
  
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            //record is deleted.
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        } 
    },
          
})