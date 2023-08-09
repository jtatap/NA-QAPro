let eswOptions = {
    baseURL: 'https://pvhservicecloud--uat.my.salesforce.com',
    contentURL: 'https://uat-pvhservicecloud.cs169.force.com/calvinklein',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D6w0000008as9',
    deploymentID: '5726w0000008OJY',
    buttonIds: '5736w0000008OJw',
    serviceName: 'Calvin_Klein_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I6w000000002KEAQ_17509a443b9',
    storageDomain: 'ck-b2cna-ps1.pvh.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
