let eswOptions = {
    baseURL: 'https://pvhservicecloud--uat.my.salesforce.com',
    contentURL: 'https://uat-pvhservicecloud.cs35.force.com/calvinklein',
    liveAgentURL: 'https://d.la3-c1cs-ph2.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la3-c1cs-ph2.salesforceliveagent.com',
    orgID: '00D2g0000000UGP',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Calvin_Klein_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LMDzEAO_1752a936421',
    storageDomain: 'ck-b2cna-ps1.pvh.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
