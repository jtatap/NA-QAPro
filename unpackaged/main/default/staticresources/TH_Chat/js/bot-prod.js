 let eswOptions = {
    baseURL: 'https://pvhservicecloud.my.salesforce.com',
    contentURL: 'https://help.usa.tommy.com/',
    liveAgentURL: 'https://d.la1-c1-ia5.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la1-c1-ia5.salesforceliveagent.com',
    orgID: '00D1U000000xmv4',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Tommy_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LME1EAO_1752a9569cc',
    storageDomain: 'tommy.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/TH_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})