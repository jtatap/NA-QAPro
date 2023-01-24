({
   
	doInit : function(component, event, helper) {
		helper.loadInitialData(component, event, helper);
	},
    
    handleSubmit : function(component, event, helper) {
        
		helper.handleSubmit(component, event, helper);    
	},
    
    handleCheckBoxChange : function(component, event, helper) {
        helper.handleCheckBoxChange(component, event, helper);
        
    },
    
    handleOnChangeReachList :  function(component, event, helper) {
    	 helper.handleOnChangeReachList(component, event, helper);
    },
    
    handleExistingPurchase :  function(component, event, helper) {
    	 helper.handleExistingPurchase(component, event, helper);
    },
    
    handlePurchaseTeam :  function(component, event, helper) {
    	 helper.handlePurchaseTeam(component, event, helper);
    },
     setMessage :  function(component, event, helper) {
    	 helper.setMessage(component, event, helper);
    },
    
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    /*
    onFirstNameFocus : function(component, event, helper) {
        component.find("firstname").setCustomValidity("");
        component.find("firstname").reportValidity();
        
    },
    
    onLastNameFocus: function(component, event, helper) {
       // component.find("lastname").setCustomValidity("");
        component.find("lastname").reportValidity();
        
    },
    
    onEmailFocus: function(component, event, helper) {
        component.find("email").setCustomValidity("");
        component.find("email").reportValidity();
        
    }
    
	*/
    uploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        component.set("v.isRemoveFilesDisplay",true);

        var files = component.get('v.files');
        for (var f in uploadedFiles) {
            if (uploadedFiles.hasOwnProperty(f)) {
                files.push({
                    'Title': uploadedFiles[f].name,
                    'Id': uploadedFiles[f].documentId
                });
            }
        }
        component.set('v.files', files);

        console.log('file.length: ' + files.length);

        var fileLimit = component.get('v.fileCountLimit');

        if (files.length >= fileLimit) {
            component.set('v.disabled', true);
        } else {
            component.set('v.disabled', false);
        }
    },
    deleteFile:function(component,event,helper){
        component.set("v.Spinner", true);

        var documentId = event.target.id;
        var files = component.get('v.files');
        var index = event.target.dataset.index;
        var fileLimit = component.get('v.fileCountLimit');

        files.splice(index, 1);

        component.set('v.files', files);
        component.set("v.Spinner", false);
        //helper.delUploadedfiles(component,documentId);
        if(files.length == 0) {
            component.set("v.isRemoveFilesDisplay",false);
            component.set('v.disabled', false);
        } else if (files.length >= fileLimit) {
            component.set('v.disabled', true);
        } else {
            component.set('v.disabled', false);
        }
    }
})