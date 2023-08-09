({
	handleCloseModal : function(component, event, helper) {
        component.find("overlayLib").notifyClose();
	},
    
    handleTransactionClick : function(cmp, event, helper) {
        
        var getObject = cmp.get("v.pointWrapper");
        
        var success = String($A.get("$Label.c.Success1"));

        $A.createComponent("c:A1_TransactionDetails",
                           {
                               "pointWrapper" : getObject,
                               
                           },
                           function(content, status) {
                               if (status === success) {
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