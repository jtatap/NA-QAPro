({
    
        
    Search: function(component, event, helper) {
        //var isValueMissing = searchField.get('v.validity').valueMissing;
        // console.log('entered into the search'+isValueMissing);
       /* if(isValueMissing) {
             console.log('entered into the search 1>>'+isValueMissing);
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{ */
            // console.log('entered into the search 2>>>'+isValueMissing);
          // else call helper function 
          var searchlength=component.get("v.searchKeyword");
       /// console.log('entered into the search 2>>>'+searchlength.length);
        if(typeof searchlength =='undefined' ||searchlength.length===0  ){
           var searchField = component.find('searchField');
            var isValueMissing = searchField.get('v.validity').valueMissing;
            component.set('v.searchResult',null);
             searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
             helper.SearchHelper(component, event);
            
        }
       /* component.set('v.columns', [
            
            {label: 'NAME', fieldName: 'Name', type: 'text'},
            {label: 'EMAIL', fieldName: 'Email', type: 'email'},
            {label: 'BRAND', fieldName: 'Brand__c', type: 'text'},
            {label: 'LOYALTY ID', fieldName: 'LoyaltyID__c', type: 'text'}
        ]);*/

    },
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        var selectedvalue = component.find("selectedContact").get("v.value");
        component.set("v.SelectedContactRecord", selectedvalue); 
               alert("v.SelectedContactRecord");
        
      
        console.log('selectedvalue-' + selectedvalue);
    },
   checkboxSelect : function(component, evt, helper) {
        //var selected = evt.getSource().get("v.value");
        console.log("val1 = "+event.target.value);
    /* var selectedaccId= document.querySelector('input[name="options"]:checked').id;
       console.log(selectedaccId);
       alert("value is"+selectedaccId);
        var selected = evt.getSource().get("v.value");
       alert("value is"+selected);
        var resultCmp;
       var selectedCon;
		 //resultCmp = cmp.find("radioGroupResult");
		selectedCon=resultCmp.set("v.value", selected);
       alert(selectedCon);
        alert(resultCmp);*/
   },
    handleRadioClick : function(component,event,helper){
        var selectedRadioOption = component.find('tokenRadioAuraId');
        console.log('entered into checkbox>>>');
                var selectedRows = event.target.Id;
		//var freqRow = component.get("v.searchResult").find(row => row.Id === event.target.id);

        var test=event.currentTarget.dataset.record;
        console.log('testt>>>'+JSON.stringify(test));
        console.log('testtttttt'+selectedRadioOption.get("v.value"));
        alert(selectedRadioOption.get("v.value"));
    },
     updateSelectedText : function(component,event,helper){
    
        var selectedRows = event.getParam('selectedRows');
         var selectedRows1 = event.getParam('row');
        console.log('inside row selection'+JSON.stringify(selectedRows));
         //console.log('inside row selection'+selectedRows1[0].Name);
         var name='';
         for (let i = 0; i < selectedRows.length; i++){
             name=selectedRows[i].Id;
        console.log("You selected: " + selectedRows[i].Id);
    }
         var cmpEvent = component.getEvent("oSelectedContactEvent");
        cmpEvent.setParams({
            "message" : selectedRows });
        cmpEvent.fire();
    
},
     handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    }
    
   
})