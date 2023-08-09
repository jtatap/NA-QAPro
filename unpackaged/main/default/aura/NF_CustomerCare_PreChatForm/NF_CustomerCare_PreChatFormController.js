/**
 * Created by mcasella on 9/11/20.
 */

({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     *
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state. 
     */
    onInit: function(cmp, evt, hlp) {
        console.log("running prechat controller");
        console.log("The brand name is1 ");
        // Get pre-chat fields defined in setup using the prechatAPI component
        var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        console.log(prechatFields);
        // Get pre-chat field types and attributes to be rendered
        var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(prechatFields);
        
        
        // Make asynchronous Aura call to create pre-chat field components
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldComponents", components);
                }
            }
        );
        console.log("The brand name is2 " );
        var getBrandName = cmp.get("c.getBrand");
       
        getBrandName.setParams({ url : window.location.href && window.location.href.substring(0, 255) });
        getBrandName.setCallback(this, function(response) {
            var state = response.getState();
            var brand = response.getReturnValue();
            console.log("The brand name is3 " + brand);
            if (state === "SUCCESS") {
                cmp.set('v.brand',brand);
            }
            else {
                cmp.set('v.brand','Calvin Klein');
            }

            if(document.getElementById("loadingContainer")){
                document.getElementById("loadingContainer").style.display = 'none';
            }
            if(document.getElementById("privacyPolicyContainer")){
                document.getElementById("privacyPolicyContainer").style.display = 'block';
            }
        });
        $A.enqueueAction(getBrandName);

    },
    
    /**
     * Event which fires when start button is clicked in pre-chat
     *
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    handleStartButtonClick: function(component, event, helper) {
        console.log('weee');
        helper.onStartButtonClick(component, event, helper);
    },
    
    handleCallButtonClick: function(component, event, helper){
        document.location.href='tel';
    }
    
    
});