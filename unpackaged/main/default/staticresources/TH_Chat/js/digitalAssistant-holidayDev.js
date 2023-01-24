 let eswOptions = {
    baseURL: 'https://pvhservicecloud--projectdev.my.salesforce.com',
    contentURL: 'https://projectdev-pvhservicecloud.cs78.force.com/tommy',
    liveAgentURL: 'https://d.la2-c1cs-ord.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ord.salesforceliveagent.com',
    orgID: '00D1k000000FO4T',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Tommy_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LME1EAO_1752a9569cc',
    storageDomain: 'neuraflash.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/TH_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js?a=9' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})