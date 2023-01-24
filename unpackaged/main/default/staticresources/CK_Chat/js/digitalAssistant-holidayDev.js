 let eswOptions = {
    baseURL: 'https://pvhservicecloud--projectdev.my.salesforce.com',
    contentURL: 'https://projectdev-pvhservicecloud.cs78.force.com/calvinklein',
    liveAgentURL: 'https://d.la2-c1cs-ord.salesforceliveagent.com',
    liveAgentContentURL: 'https://d.la2-c1cs-ord.salesforceliveagent.com',
    orgID: '00D1k000000FO4T',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Calvin_Klein_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LMDzEAO_1752a936421',
    storageDomain: 'neuraflash.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};
// comment
$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js?a=3' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})