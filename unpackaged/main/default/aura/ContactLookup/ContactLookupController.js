({
    doInit : function(component,event,helper){
        var selectedId = component.get("v.selectedId");
        var action = component.get("c.getObjectDetails");
        component.set('v.columns', [
            
            {label: 'NAME', fieldName: 'Name', type: 'text',sortable: true,},
            {label: 'EMAIL', fieldName: 'Email', type: 'email',sortable: true,},
            {label: 'BRAND', fieldName: 'Brand__c', type: 'text',sortable: true,},
            {label: 'LOYALTY ID', fieldName: 'LoyaltyID__c', type: 'text',sortable: true,},
             {label: 'ECOMM CONNECTED', fieldName: 'Ecomm_Connected__c', type: 'text',sortable: true,}
        ]);
        action.setParams({'ObjectName' : component.get("v.objectAPIName")});
        action.setCallback(this, function(response) {
            var details = response.getReturnValue();
            component.set("v.IconName", details.iconName);
            component.set("v.objectLabel", details.label);
            component.set("v.objectLabelPlural", details.pluralLabel);
            if (selectedId == null || selectedId.trim().length <= 0) {
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
        
        var returnFields =  component.get("v.returnFields"),
            queryFields =  component.get("v.queryFields");
        
        if (returnFields == null || returnFields.length <= 0) {
            component.set("v.returnFields", ['Name']);
        }
        
        if (queryFields == null || queryFields.length <= 0) {
            component.set("v.queryFields", ['Name']);
        }
        
        //help for cancelling the create new record
        //find the latest accessed record for the user
        if (component.get("v.showAddNew")) {
            var action = component.get("c.GetRecentRecords");
            action.setParams({
                'ObjectName' : component.get("v.objectAPIName"),
                'ReturnFields' :  null,
                'MaxResults' : 1
            });
            action.setCallback(this, function(response) {
                var results = response.getReturnValue();
                if (results != null && results.length > 0) {
                    component.lastRecordId = results[0].Id;
                }
            });
            $A.enqueueAction(action);
        }
        if (selectedId != null && selectedId.trim().length > 0) {
            var action = component.get("c.GetRecord"),
                returnFields = component.get("v.returnFields");
            action.setParams({'ObjectName' : component.get("v.objectAPIName"),
                              'ReturnFields': returnFields,
                              'Id': component.get("v.selectedId")});
            action.setCallback(this, function(response) {
                var results = response.getReturnValue();
                results = helper.processResults(results, returnFields);
                component.set("v.selectedName", results[0].Field0);
                component.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }
    },
    
    onFocus : function(component,event,helper){
        var inputBox = component.find("lookup-input-box"),
            searchText = component.get("v.searchText") || '';
        
        $A.util.addClass(inputBox, 'slds-is-open');
        $A.util.removeClass(inputBox, 'slds-is-close');
        
        if (component.get("v.showRecent") && searchText.trim() == '') {
            component.set("v.isSearching", true);        
            var action = component.get("c.GetRecentRecords"),
                returnFields = component.get("v.returnFields");
            
            action.setParams({
                'ObjectName' : component.get("v.objectAPIName"),
                'ReturnFields' :  returnFields,
                'MaxResults' : component.get("v.maxResults")
            });
            action.setCallback(this, function(response) {
                var results = response.getReturnValue();
                if (results != null) {
                    component.set("v.statusMessage", results.length > 0 ? null : 'No recent records.' );
                    component.set("v.searchResult", 
                                  helper.processResults(results, returnFields));
                } else {
                    component.set("v.statusMessage", "Search Error!" );
                }
                component.set("v.isSearching", false);
            });
            $A.enqueueAction(action);
        }
        
    },
    
    onBlur : function(component,event,helper){       
        var inputBox = component.find("lookup-input-box");
        $A.util.addClass(inputBox, 'slds-is-close');
        $A.util.removeClass(inputBox, 'slds-is-open');
        
        $A.util.removeClass(component.find("lookup-input-box"),'slds-has-focus');
        
    },
    
    onKeyUp : function(component, event, helper) {
        
        var searchText = component.get('v.searchText');
        console.log('searchText'+searchText);
        //do not repeat the search if nothing changed
        /*  if (component.lastSearchText !== searchText) {
            component.lastSearchText = searchText;
        } else {
            return;
        }*/
        
        component.set("v.isSearching", true); 
        if (searchText == null || searchText.trim().length < 3 ) {
            component.set("v.searchResult", []);
            component.set("v.statusMessage", null);
            return;
        }
        
        component.set("v.SearchableText", searchText); 
        console.log('searchText'+searchText);
        var action = component.get("c.SearchRecords"),
            returnFields = component.get("v.returnFields");
        console.log('returnFields'+returnFields);
        action.setParams({
            'ObjectName' : component.get("v.objectAPIName"),
            'ReturnFields' :  returnFields,
            'QueryFields' :  component.get("v.queryFields"),
            'SearchText': searchText,
            'SortColumn' : component.get("v.sortColumn"),
            'SortOrder' : component.get("v.sortOrder"),
            'MaxResults' : component.get("v.maxResults"),
            'Filter' : component.get("v.filter")
        });
        
        action.setCallback(this, function(response) {
            var results = response.getReturnValue();
            console.log('returnFields'+returnFields);
            if (results != null) {
                component.set("v.statusMessage", results.length > 0 ? null : 'No records found.' );
                component.set("v.searchResult", 
                              helper.processResults(results, returnFields, searchText));
            } else {
                component.set("v.statusMessage", 'Search Error!' );
            }
            component.set("v.isSearching", false);
        });
        $A.enqueueAction(action);
        
    },
    
    onSelectItem : function(component, event, helper) {
        var selectedId = event.currentTarget.dataset.id;
        component.set("v.selectedId", selectedId);
        var results = component.get("v.searchResult");
        for (var i = 0; i < results.length; i++) {
            if (results[i].Id == selectedId) {
                component.set("v.selectedName", results[i].Field0.replace("<mark>","").replace("</mark>",""));
                break;
            }
        }
        $A.enqueueAction(component.get("c.onBlur"));
    },
    
    removeSelectedOption : function(component, event, helper) {
        component.set("v.selectedId", null);
    },
    
    createNewRecord : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord"),
            objectName = component.get("v.objectAPIName"),
            returnFields = component.get("v.returnFields");
        createRecordEvent.setParams({
            "entityApiName": objectName,
            "navigationLocation" : "LOOKUP",
            "panelOnDestroyCallback": function(event) {
                let action = component.get("c.GetRecentRecords");
                action.setParams({'ObjectName' : objectName,
                                  'MaxResults' : 1,
                                  'ReturnFields': returnFields});
                action.setCallback(this, function(response) {
                    var records = response.getReturnValue();
                    if (records != null && records.length > 0) {
                        if (records[0].Id != component.lastRecordId) {
                            component.set("v.selectedId", records[0].Id);
                            component.set("v.selectedName", records[0][returnFields[0]]);
                            component.lastRecordId = records[0].Id;
                        }
                    }
                });
                $A.enqueueAction(action);              
            }
        });
        createRecordEvent.fire();
    },
    
    createNewCaseRecord : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact"
        });
        createRecordEvent.fire();
    },
    
    searchAllRecords : function(component, event, helper) {
        var searchText = component.get('v.searchText');
        var evt = $A.get("e.force:navigateToComponent");      
        evt.setParams({
            componentDef:"c:searchAllContacts",
            componentAttribute : {
                searchtext : searchText
                
            }
        });
        
        evt.fire();
    },
    
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
        var childCmp = component.find("cComp")
        childCmp.sampleMethod();
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        alert('thanks for like Us :)');
        component.set("v.isOpen", false);
    },
    
    
    Search: function(component, event, helper) {
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        alert('searchKeyWord***'+searchKeyWord);
        console.log('searchField***'+searchField);
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
            // else call helper function 
            helper.SearchHelper(component, event);
        }
    },
    submit: function(component, event, helper) {
        helper.SubmitHelper(component, event); 
    },
    handleComponentEvent:function(component, event, helper) {
        var message = event.getParam("message");
        console.log('Entered into the event'+ message);
        for (let i = 0; i < message.length; i++){
            name=message[i].Id;
            console.log("You selected: " + message[i].Id);
            component.set("v.selectedId",message[i].Id);
            component.set("v.selectedName",message[i].Name);
        }
        
        console.log('Entered into the after set>>>'+component.get('v.selectedId'));
    }
})