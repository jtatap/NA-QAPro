let eswOptions = {
    baseURL: 'https://pvhservicecloud.my.salesforce.com',
    contentURL: 'https://help.calvinklein.com/',
    liveAgentURL: 'https://d.la1-c1-ia5.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la1-c1-ia5.salesforceliveagent.com',
    orgID: '00D1U000000xmv4',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Calvin_Klein_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LMDzEAO_1752a936421',
    storageDomain: window.location.href.indexOf('calvinklein.ca') !== -1 ? 'calvinklein.ca': 'calvinklein.us', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
