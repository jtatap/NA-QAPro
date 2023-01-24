let eswOptions = {
    baseURL: 'https://pvhservicecloud--uat.my.salesforce.com',
    contentURL: 'https://uat-pvhservicecloud.cs169.force.com/calvinklein',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D6w0000008as9',
    deploymentID: '5726w0000008OJ3',
    buttonIds: '5736w0000008OJI',
    serviceName: 'Calvin_Klein_Prioritized_Chat',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I6w000000001nEAA_1748eeb2133',
    storageDomain: 'localhost', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
