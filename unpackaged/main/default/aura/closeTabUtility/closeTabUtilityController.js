/**
 * Created by bryananderson on 11/21/19.
 */

({
    onTabClosed : function(component, event, helper) {
        console.log('onTabClosed toggleCloseCaseTab');

        var tabId = event.getParam('tabId');
        console.log("Tab closed: " + tabId);

        var tabs = component.get("v.tabObj");
        var tabsJSON = JSON.parse(JSON.stringify(tabs));

        var tabRecId = tabsJSON[tabId];

        delete tabsJSON[tabId];

        console.log('tabRecId: ' + tabRecId);
        console.log('tabsJSON: ' + tabsJSON);

        helper.tabClosed(component, event, helper, tabRecId);
    },
    onTabRefreshed : function(component, event, helper) {
        console.log('onTabRefreshed toggleCloseCaseTab');

        var tabs = component.get("v.tabObj");

        console.log('OLD tabs START');
        console.log(tabs);
        console.log('OLD tabs END');

        var objTemp = {};

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('response.length: ' + response.length);
            for(var i = 0; i < response.length; i++) {
                console.log('tabId: ' + response[i].tabId);
                console.log('title: ' + response[i].title);
                console.log('recordId: ' + response[i].recordId);


                console.log(i);
                var tabIdResp = response[i].tabId;
                var tabRecId = response[i].recordId;

                objTemp[tabIdResp] = tabRecId;
                console.log("value after iteration"+i+" - " + objTemp);

                /*if (response[i].title == 'Unable to load') {
                    workspaceAPI.disableTabClose({
                        tabId: response[i].tabId,
                        disabled: false
                    });

                    workspaceAPI.closeTab({tabId: response[i].tabId});
                }*/
            }

            console.log('NEW tabs START');
            console.log(objTemp);
            console.log('NEW tabs END');

            component.set("v.tabObj", objTemp);
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    onTabFocused : function(component, event, helper) {
        console.log('onTabFocused toggleCloseCaseTab');

        var tabs = component.get("v.tabObj");

        console.log('OLD tabs START');
        console.log(tabs);
        console.log('OLD tabs END');

        var objTemp = {};

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            console.log('response.length: ' + response.length);
            for(var i = 0; i < response.length; i++) {
                console.log('tabId: ' + response[i].tabId);
                console.log('title: ' + response[i].title);
                console.log('recordId: ' + response[i].recordId);


                console.log(i);
                var tabIdResp = response[i].tabId;
                var tabRecId = response[i].recordId;

                objTemp[tabIdResp] = tabRecId;
                console.log("value after iteration"+i+" - " + objTemp);

                /*if (response[i].title == 'Unable to load') {
                    workspaceAPI.disableTabClose({
                        tabId: response[i].tabId,
                        disabled: false
                    });

                    workspaceAPI.closeTab({tabId: response[i].tabId});
                }*/
            }

            console.log('NEW tabs START');
            console.log(objTemp);
            console.log('NEW tabs END');

            component.set("v.tabObj", objTemp);
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    handleApplicationEvent: function(component, event) {
        console.log('handleApplicationEvent');
        var recordId = event.getParam("recordId");
        console.log('recordId: ' +  recordId);
        // set the handler attributes based on event data
        component.set("v.recordId", recordId);
    }
});