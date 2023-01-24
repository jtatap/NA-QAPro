({
	handleCloseModal : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
		//alert('Closed');
	},
    
    handleTransactionClick : function(cmp, event, helper) {
        //alert('inside handle click');
        
        var getObject = cmp.get("v.pointWrapper");
        
        
        $A.createComponent("c:A1_TransactionDetails",
                           {
                               "pointWrapper" : getObject,
                               
                           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   var modalBody = content;
                                   cmp.find('overlayTransactionDetail').showCustomModal({
                                       //header: "Welcome to Transaction Detail",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       cssClass: "model12",
                                       closeCallback: function(ovl) {
                                           console.log('Overlay is closing');
                                       }
                                   }).then(function(overlay){
                                       console.log("Overlay is made");
                                   });
                               }
                           });
    
    }
})