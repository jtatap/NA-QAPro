 let eswOptions = {
    baseURL: 'https://pvhservicecloud--qapro.my.salesforce.com',
    contentURL: 'https://qapro-pvhservicecloud.cs159.force.com/tommy',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com/content',
    orgID: '00D7X000000E9p9',
    deploymentID: '5721U0000001qRs',
    buttonIds: '5731U0000001tAW',
    serviceName: 'Tommy_Prioritized_Chat',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I1U000000PKQSUA4_16e5b4e956e',
    storageDomain: 'pvh.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/TH_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})