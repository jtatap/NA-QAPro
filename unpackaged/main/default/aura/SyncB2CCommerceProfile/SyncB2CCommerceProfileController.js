({
    init : function (cmp) {
        var recordId = cmp.get("v.recordId");
        var flow = cmp.find("flowData");
        flow.startFlow("B2CCommerce_QuickAction_Contact_ContactRetrieve");
    }
})