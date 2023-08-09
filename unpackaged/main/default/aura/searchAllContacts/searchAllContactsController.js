({
    
    Search: function(component, event, helper) {
          var searchlength=component.get("v.searchKeyword");
        if(typeof searchlength =='undefined' ||searchlength.length===0  ){
           var searchField = component.find('searchField');
            var isValueMissing = searchField.get('v.validity').valueMissing;
            component.set('v.searchResult',null);
             searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
             helper.SearchHelper(component, event);
            
        }
       

    },
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        var selectedvalue = component.find("selectedContact").get("v.value");
        component.set("v.SelectedContactRecord", selectedvalue); 
               alert("v.SelectedContactRecord");
        
      
        console.log('selectedvalue-' + selectedvalue);
    },
   checkboxSelect : function(component, evt, helper) {
       
        console.log("val1 = "+event.target.value);
    
   },
    handleRadioClick : function(component,event,helper){
        var selectedRadioOption = component.find('tokenRadioAuraId');
        console.log('entered into checkbox>>>');
                var selectedRows = event.target.Id;
		

        var test=event.currentTarget.dataset.record;
        console.log('testt>>>'+JSON.stringify(test));
        console.log('testtttttt'+selectedRadioOption.get("v.value"));
        alert(selectedRadioOption.get("v.value"));
    },
     updateSelectedText : function(component,event,helper){
    
        var selectedRows = event.getParam('selectedRows');
         var selectedRows1 = event.getParam('row');
        console.log('inside row selection'+JSON.stringify(selectedRows));
        
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