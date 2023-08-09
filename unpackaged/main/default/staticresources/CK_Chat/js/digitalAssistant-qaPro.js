 let eswOptions = {
    baseURL: 'https://pvhservicecloud--qapro.my.salesforce.com',
    contentURL: 'https://qapro-pvhservicecloud.cs159.force.com/pvh',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D7X000000E9p9',
    deploymentID: '5727X000000Gmb7',
    buttonIds: '5737X000000Gmb2',
    serviceName: 'Calvin_Klein_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I7X000000GmcAUAS_174eb273cbe',
    storageDomain: 'neuraflash.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};
// comment
$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js?a=5' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
