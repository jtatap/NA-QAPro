 let eswOptions = {
    baseURL: 'https://pvhservicecloud--holidaydev.my.salesforce.com',
    contentURL: 'https://holidaydev-pvhservicecloud.cs198.force.com/tommy',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D050000008afk',
    deploymentID: '57205000000CaSU',
    buttonIds: '57305000000CaSF',
    serviceName: 'Tommy_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I050000004CB9EAM_1749e9a0001',
    storageDomain: 'neuraflash.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/TH_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})