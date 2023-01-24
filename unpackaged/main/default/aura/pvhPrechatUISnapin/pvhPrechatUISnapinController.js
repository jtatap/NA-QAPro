/**
 * Created by bryananderson on 2019-08-28.
 */

({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     *
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    onInit: function(component, event, helper) {
        // Get prechat fields defined in setup using the prechatAPI component.
        var prechatFields = component.find("prechatAPI").getPrechatFields();

        // Get prechat field types and attributes to be rendered.
        var prechatFieldComponentsArray = helper.getPrechatFieldAttributesArray(prechatFields);

        // Make asynchronous Aura call to create prechat field components.
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    component.set("v.prechatFieldComponents", components);

                    var laSettings = component.find("settingsAPI").getLiveAgentSettings();

                    component.set("v.laDeploymentId", laSettings.liveAgentDeploymentId);

                    var laDeploymentId = component.get("v.laDeploymentId");

                    var getEsRecAction = component.get("c.getEmbeddedServiceDetailRecord");
                    getEsRecAction.setParams({
                        dId: laDeploymentId
                    });
                    getEsRecAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var resp = response.getReturnValue();

                            if (resp != null) {
                                if (resp.PrechatBackgroundImg != undefined) {
                                    component.set('v.hasPrechatBackground', true);
                                    component.set('v.prechatBackground', 'background-image: url(' + resp.PrechatBackgroundImg + ')');
                                } else {
                                    component.set('v.hasPrechatBackground', false);
                                }
                            }
                        }
                        else if (state === "INCOMPLETE") {
                            // do something
                        }
                        else if (state === "ERROR") {
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
                    $A.enqueueAction(getEsRecAction);
                }
            }
        );

    },

    /**
     * Event which fires when start button is clicked in prechat.
     *
     * @param component - The component for this state.
     * @param event - The Aura event.
     * @param helper - The helper for this state.
     */
    handleStartButtonClick: function(component, event, helper) {
        //Validate that all required fields are populated
        helper.validateFields(component,event);

        //If validation is successful, then call the standard prechat validation
        if(component.get("v.validationSuccessful")){
            helper.onStartButtonClick(component);
        }
    }
});