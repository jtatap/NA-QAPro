 let eswOptions = {
    baseURL: 'https://pvhservicecloud--qapro.my.salesforce.com',
    contentURL: 'https://qapro-pvhservicecloud.cs59.force.com/pvh',
    liveAgentURL: 'https://c.la1-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://d.la1-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D2C000000Cmsr',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Calvin_Klein_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LMDzEAO_1752a936421',
    storageDomain: 'neuraflash.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};
// comment
$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js?a=6' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
