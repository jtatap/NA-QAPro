let eswOptions = {
    baseURL: 'https://pvhservicecloud--qapro.my.salesforce.com',
    contentURL: 'https://qapro-pvhservicecloud.cs159.force.com/calvinklein',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D7X000000E9p9',
    deploymentID: '5727X000000GmaT',
    buttonIds: '5737X000000GmaY',
    serviceName: 'Calvin_Klein_Prioritized_Chat',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I7X000000GmadUAC_1747a7e2892',
    storageDomain: 'localhost', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
