({
    doInit: function (cmp, event, helper) {

        var success = String($A.get("$Label.c.Success1"));
        var incomplete = String($A.get("$Label.c.Incomplete"));
        var error = String($A.get("$Label.c.Error1"));

        var action = cmp.get("c.getLoyaltyId");
        action.setParams({
            recordIds: cmp.get("v.recordId")
        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === success) {
                // Alert the user with the value returned 
                // from the server
                cmp.set("v.rewardWrapper", response.getReturnValue());
                cmp.set("v.numRecords", response.getReturnValue().length);

            } else if (state === incomplete) {
                // do something
            } else if (state === error) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },

    handleClick: function (cmp, event, helper) {
        cmp.set("v.pointWrapperObject", null);
        var idx = event.target.id;
        var transactionID = cmp.get("v.rewardWrapper")[idx].transactionId;
        var gotPointsData = cmp.get("v.pointWrapper");
        console.log('Data = ' + JSON.stringify(gotPointsData));
        for (var i = 0; i < gotPointsData.length; i++) {

            if (gotPointsData[i].Description == transactionID) {
                cmp.set("v.pointWrapperObject", gotPointsData[i]);
            }

        }

        if (cmp.get("v.pointWrapperObject") != null) {
            $A.createComponent("c:A1_TransactionDetails", {
                    "pointWrapper": cmp.get("v.pointWrapperObject")
                },
                function (content, status) {
                    if (status === success) {
                        var modalBody = content;
                        cmp.find('overlayRewardsDetail').showCustomModal({
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: "model12",
                            closeCallback: function (ovl) {
                                console.log('Overlay is closing');
                            }
                        }).then(function (overlay) {
                            console.log("Overlay is made");
                        });
                    }
                });

        } else {
            helper.showToast(cmp, event, "error", "Error: ", "Transaction Details Not Found");
        }
    },

    handleApplicationEvent: function (cmp, event) {
        //Get the event message attribute
        var gotPointWrapper = event.getParam("pointWrapperFromEvent");
        //Set the handler attributes based on event data 
        cmp.set("v.pointWrapper", gotPointWrapper);
    },

    // this function automatic call by aura:waiting event  
    showSpinner: function (component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true);
    },

    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function (component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }


})