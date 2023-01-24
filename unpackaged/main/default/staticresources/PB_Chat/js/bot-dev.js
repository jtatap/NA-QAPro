let eswOptions = {
    baseURL: 'https://pvhservicecloud--holidaydev.my.salesforce.com',
    contentURL: 'https://holidaydev-pvhservicecloud.cs198.force.com/izod',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D050000008afk',
    deploymentID: '57205000000CaRq',
    buttonIds: '57305000000CaSF',
    serviceName: 'Digital_Assistant',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I050000004CAkEAM_1746aeec446',
    storageDomain: 'localhost', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/PB_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
