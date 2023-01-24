function checkOptions(obj){
    if(!obj)
        return {
            baseURL: '',
            contentURL: '',
            liveAgentURL: '',
            orgID: '',
            deploymentID: '',
            buttonIds: ''
        };
    var reqKeys = ['baseURL', 'contentURL', 'liveAgentURL', 'orgID', 'deploymentID' ];
    for(var i = 0; i < reqKeys.length; i++){
        if(!obj[reqKeys[i]])
            obj[reqKeys[i]] = '';
    }
    return obj;
}

function isUserInfoEmpty(ui) {
    if(!ui)
        return true;
    var reqKeys = ['userType', 'firstname', 'lastname', 'email', 'saltedid', 'isLoggedin'];
    for(var i = 0; i < reqKeys.length; i++) {
        if(ui[reqKeys[i]])
            return false;
    }

    ui.isUserLoggedin = ui.firstname && ui.email

    return true;
}

function getUserInfo(url){
    return new Promise((resolve, reject) => {
        if (!isUserInfoEmpty(window.userInfo)) {
            resolve(window.userInfo)
        } else {
            fetch(url)
                .then(
                    result => {
                        return result.json();
                    }
                )
                .then(
                    data => {
                        window.userInfo = data;
                        resolve(data);
                    }
                )
                .catch(
                    err => {
                        reject(err);
                    }
                )
        }
    });
}


var options = checkOptions(options);


function initBot(options) {

    var url = location.href && location.href.substring(0,255);
    var split = url.split('?');
    var isBotOpen = false;
    if(split.length >1){
        for (var i = 0; i < split.length; i++) {
            if(split[i].includes('bot=open')) {
                isBotOpen = true;
            }
        }
    }

    if(options.enableLogging === true) {
        console.log('>>initBot options=' + JSON.stringify(options))
        console.log('isBotOpen>>'+isBotOpen);
    }

    //load Bot CSS
    if(options.contentURL && options.contentURL.length > 0){
        $('<link/>', {
            rel: 'stylesheet',
            type: 'text/css',
            href: options.contentURL + options.resourceBase + '/css/bot.css?t=' + (options.enableLogging ? Date.now() : '')
        }).appendTo('head');
    }

    //define variables to be passed to Embedded Service
    let prechatFormDetails = [
        {"label": "CreatedByMethod",
        "value": "UI",
        "transcriptFields": [],
        "displayToAgent": true
        }, {
            "label": "Brand",
            "value": "2",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "CaseBrand",
            "value": "2",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Web Email",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Web Phone",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Web Name",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Account First Name",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Account Last Name",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Case Origin",
            "value": "Chat",
            "transcriptFields": [],
            "displayToAgent": true
        }, {
            "label": "Page URL",
            "value": location.href && location.href.substring(0,255),
            "displayToAgent": false,
            "transcriptFields": ['URL__c']
        }];

    let prechatInfo = [{
        "entityName": "Contact",
        "showOnCreate": true,
        "linkToEntityName": "Case",
        "linkToEntityField": "ContactId",
        "saveToTranscript": "Contact",
        "entityFieldMaps": [{
            "isExactMatch": false,
            "fieldName": "LastName",
            "doCreate": false,
            "doFind": false,
            "label": "LastName"
        }, {
            "isExactMatch": false,
            "fieldName": "FirstName",
            "doCreate": false,
            "doFind": false,
            "label": "FirstName"
        }, {
            "isExactMatch": true,
            "fieldName": "Email",
            "doCreate": true,
            "doFind": true,
            "label": "Email"
        }, {
            "isExactMatch": true,
            "fieldName": "Brand_Id__c",
            "doCreate": true,
            "doFind": true,
            "label": "Brand"
        }, {
            "isExactMatch": true,
            "fieldName": "Phone",
            "doCreate": true,
            "doFind": true,
            "label": "Phone"
        }, {
            "isExactMatch": true,
            "fieldName": "CreatedByMethod__c",
            "doCreate": true,
            "doFind": false,
            "label": "CreatedByMethod"
        }]
    }
//    ,{
//        "entityName": "Case",
//        "showOnCreate": true,
//        "saveToTranscript": "Case",
//        "entityFieldMaps": [{
//            "isExactMatch": false,
//            "fieldName": "Brand__c",
//            "doCreate": true,
//            "doFind": false,
//            "label": "CaseBrand"
//        }, {
//            "isExactMatch": false,
//            "fieldName": "SuppliedEmail",
//            "doCreate": true,
//            "doFind": false,
//            "label": "Web Email"
//        }, {
//            "isExactMatch": false,
//            "fieldName": "SuppliedPhone",
//            "doCreate": true,
//            "doFind": false,
//            "label": "Web Phone"
//        }, {
//            "isExactMatch": false,
//            "fieldName": "SuppliedName",
//            "doCreate": true,
//            "doFind": false,
//            "label": "Web Name"
//        }, {
//            "label": "Account First Name",
//            "transcriptFields": [],
//            "displayToAgent": true
//        }, {
//            "label": "Account Last Name",
//            "transcriptFields": [],
//            "displayToAgent": true
//        }, {
//            "isExactMatch": false,
//            "fieldName": "Origin",
//            "doCreate": true,
//            "doFind": false,
//            "label": "Case Origin"
//        }]
//    }
    ];

    let userInfo = {};

    loadBot(options, prechatFormDetails, prechatInfo)

}

function loadBot(options, prechatFormDetails, prechatInfo){

    var minMaxObserver = new MutationObserver(function (mutations, me) {
        mutations.forEach(function(mutation) {
            //console.log(mutation.type);
            if (mutation.target.className.indexOf('sidebarMaximized') != -1) {
                if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {

                window.parent.postMessage({
                                    frameHeight: embedded_svc.settings.widgetHeight,
                                    frameWidth: embedded_svc.settings.widgetWidth,
                                    parentMarginRight: 0
                                }, '*');
                }
                else {
                    window.parent.postMessage({
                                        frameHeight: embedded_svc.settings.widgetHeight,
                                        frameWidth: embedded_svc.settings.widgetWidth,
                                        parentMarginRight: 140
                                    }, '*');
                }

            } else if (mutation.target.className.indexOf('sidebarMinimized') != -1) {
                var height = document.querySelector('.helpButton').clientHeight;
                var width = document.querySelector('.helpButton').clientWidth;
                 if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                 window.parent.postMessage({
                                     frameHeight: 100,
                                     frameWidth: width,
                                     parentMarginRight: 30
                                 }, '*');
                 }
                 else {
                     window.parent.postMessage({
                                         frameHeight: 100,
                                         frameWidth: width,
                                         parentMarginRight: 140
                                     }, '*');
                 }

            }
        });
    });

    function addObserverIfDesiredNodeAvailable() {
        var minMaxModal = document.querySelector('.modalContainer');

        if(!minMaxModal) {
            window.setTimeout(addObserverIfDesiredNodeAvailable,500);
            return;
        }
        // start observing
        minMaxObserver.observe(minMaxModal, {
            attributes: true
        });
    }

    addObserverIfDesiredNodeAvailable();


    // On page load set the correct size of the iframe to account for either CWAE/Contact Us or Session Continuity.
    function helpButtonLoaded() {
        var helpButton = document.querySelector('.helpButton');
        if (!helpButton) {
            window.setTimeout(helpButtonLoaded, 500);
            return;
        }
        //var height = document.querySelector('.uiButton.helpButtonEnabled').clientHeight;
        //var width = document.querySelector('.helpButton').clientWidth;
        //console.log(height); // check the message is being sent correctly
        //console.log(width); // check the message is being sent correctly
            if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                 window.parent.postMessage({
                     frameHeight: 85,
                     frameWidth: 38,
                     parentMarginRight: 0,
                     parentMarginBottom: 40
                 }, '*');
            } else {
                window.parent.postMessage({
                    frameHeight: 66,
                    frameWidth: 280,
                    parentMarginRight: 140,
                }, '*');
            }

//        if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
//             window.parent.postMessage({
//                 frameHeight: height,
//                 frameWidth: width,
//                 parentMarginRight: 30,
//                 parentMarginBottom: 100
//             }, '*');
//        } else {
//            window.parent.postMessage({
//                frameHeight: height,
//                frameWidth: width,
//                parentMarginRight: 140,
//                parentMarginBottm: 0
//            }, '*');
//        }
    }
    window.onload = helpButtonLoaded();

    var initESW = function(gslbBaseURL, buttonId, deploymentId) {
        embedded_svc.settings.displayHelpButton = true; //Or false
        embedded_svc.settings.language = 'en-US'; // For example, enter 'en' or 'en-US'

        embedded_svc.settings.enabledFeatures = ['LiveAgent'];
        embedded_svc.settings.entryFeature = 'LiveAgent';

        embedded_svc.settings.storageDomain = options.storageDomain;

        embedded_svc.settings.defaultMinimizedText = 'Tommy Hilfiger Digital Assistant';
        embedded_svc.settings.avatarImgURL = options.contentURL + eswOptions.resourceBase + '/img/live_agent_icon.png';
        embedded_svc.settings.chatbotAvatarImgURL = options.contentURL + eswOptions.resourceBase + '/img/FLAG_32x32.svg';

        embedded_svc.settings.extraPrechatFormDetails =  prechatFormDetails || [];
        if(options.enableLogging === true){
            console.log('extraPrechatFormDetails='+JSON.stringify(embedded_svc.settings.extraPrechatFormDetails));
        }
        embedded_svc.settings.extraPrechatInfo = [];


        //window.serviceName = embeddedServiceName;

        document.addEventListener(
            "setCaseFields",
            function(event) {
                //sets Case Web Email value based on Email provided in Live Agent prechat
                if (embedded_svc.settings.extraPrechatFormDetails) {
                    embedded_svc.settings.extraPrechatFormDetails[3].value = event.detail.webEmail;
                    //sets Case Web Phone value based on Phone provided in Live Agent prechat
                    embedded_svc.settings.extraPrechatFormDetails[4].value = event.detail.webPhone;
                    //sets Case Web Name value based on First Name and Last Name provided in Live Agent prechat
                    embedded_svc.settings.extraPrechatFormDetails[5].value = event.detail.webName;
                    //sets Account First Name value based on First Name provided in Live Agent prechat
                    embedded_svc.settings.extraPrechatFormDetails[6].value = event.detail.firstName;
                    //sets Account Last Name value based on Last Name provided in Live Agent prechat
                    embedded_svc.settings.extraPrechatFormDetails[7].value = event.detail.lastName;
                }
                // Fire startChat callback.
                event.detail.callback();
            },
            false
        );
        embedded_svc.settings.widgetWidth = 320;
        embedded_svc.settings.widgetHeight = 550;


        //for direct to Live Chat routing
        embedded_svc.init(
            options.baseURL,
            options.contentURL,
            gslbBaseURL,
            options.orgID,
            options.serviceName,
            {
                baseLiveAgentContentURL: options.liveAgentURL + '/content',
                deploymentId: deploymentId,
                buttonId: buttonId,
                baseLiveAgentURL: options.liveAgentURL+'/chat',
                eswLiveAgentDevName: options.eswLiveAgentDevName,
                isOfflineSupportEnabled: false
            }
        );

        embedded_svc.addEventHandler("afterDestroy", function() {
            if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                 window.parent.postMessage({
                     frameHeight: 85,
                     frameWidth: 38,
                     parentMarginRight: 0,
                     parentMarginBottom: 40
                 }, '*');
            } else {
                window.parent.postMessage({
                    frameHeight: 66,
                    frameWidth: 280,
                    parentMarginRight: 140,
                }, '*');
            }
        });

        embedded_svc.addEventHandler("afterMinimize", function() {
            var height = document.querySelector('.embeddedServiceSidebarMinimizedDefaultUI').clientHeight;
            var width = document.querySelector('.embeddedServiceSidebarMinimizedDefaultUI').clientWidth;
            if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                 window.parent.postMessage({
                     frameHeight: 85,
                     frameWidth: 38,
                     parentMarginRight: 0,
                     parentMarginBottom: 40
                 }, '*');
            } else {
                window.parent.postMessage({
                    frameHeight: 66,
                    frameWidth: 280,
                    parentMarginRight: 140,
                }, '*');
            }

            var minimizedObserver = new MutationObserver(function (mutations, me) {
                // 'mutations' is an array of mutations that occurred
                // 'me' is the MutationObserver instance
                var minimizedObserverEl = document.querySelector('.embeddedServiceSidebarMinimizedDefaultUI');
                if (minimizedObserverEl) {
                    var height = document.querySelector('.embeddedServiceSidebarMinimizedDefaultUI').clientHeight;
                    var width = document.querySelector('.embeddedServiceSidebarMinimizedDefaultUI').clientWidth;
                    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                         window.parent.postMessage({
                             frameHeight: 85,
                             frameWidth: 38,
                             parentMarginRight: 0,
                             parentMarginBottom: 40
                         }, '*');
                    } else {
                        window.parent.postMessage({
                            frameHeight: 66,
                            frameWidth: 280,
                            parentMarginRight: 140,
                        }, '*');
                    }
                    console.log("after minimized height-" + height);
                    console.log("after minimized width-" + width);

                    me.disconnect(); // stop observing
                    return;
                }
            });

            // start observing
            minimizedObserver.observe(document, {
                childList: true,
                subtree: true
            });
        });

        embedded_svc.addEventHandler("afterMaximize", function() {
            var height = document.querySelector('.dockableContainer').clientHeight;
            var width = document.querySelector('.dockableContainer').clientWidth;
            if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                 window.parent.postMessage({
                     frameHeight: embedded_svc.settings.widgetHeight,
                     frameWidth: embedded_svc.settings.widgetWidth,
                     parentMarginRight: 30,
                     parentMarginBottom: 40
                 }, '*');
            } else {
                window.parent.postMessage({
                    frameHeight: embedded_svc.settings.widgetHeight,
                    frameWidth: embedded_svc.settings.widgetWidth,
                    parentMarginRight: 140,
                }, '*');
            }

            var maximizedObserver = new MutationObserver(function (mutations, me) {
                // 'mutations' is an array of mutations that occurred
                // 'me' is the MutationObserver instance
                var maximizedObserverEl = document.querySelector('.dockableContainer');
                if (maximizedObserverEl) {
                    var height = document.querySelector('.dockableContainer').clientHeight;
                    var width = document.querySelector('.dockableContainer').clientWidth;
                    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
                     window.parent.postMessage({
                         frameHeight: embedded_svc.settings.widgetHeight,
                         frameWidth: embedded_svc.settings.widgetWidth,
                         parentMarginRight: 0,
                         parentMarginBottom: 40
                     }, '*');
                } else {
                    window.parent.postMessage({
                        frameHeight: embedded_svc.settings.widgetHeight,
                        frameWidth: embedded_svc.settings.widgetWidth,
                        parentMarginRight: 140,
                    }, '*');
            }
                               console.log("after maximized widgetHeight- " + embedded_svc.settings.widgetHeight);
                    console.log("after maximized widgetWidth-" + embedded_svc.settings.widgetWidth);
                    console.log("after maximized height-" + height);
                    console.log("after maximized width-" + width);
                    me.disconnect(); // stop observing
                    return;
                }
            });

            // start observing
            maximizedObserver.observe(document, {
                childList: true,
                subtree: true
            });
        });



    };

    if (!window.embedded_svc) {
        var s = document.createElement('script');
        s.setAttribute('src', options.baseURL + '/embeddedservice/5.0/esw.min.js');
        s.onload = function() {
            initESW(null, options.buttonIds, options.deploymentID);
        };
        document.body.appendChild(s);
    } else {
        initESW('https://service.force.com', options.buttonIds, options.deploymentID);
    }
}