let eswOptions = {
    baseURL: 'https://pvhservicecloud--holidaydev.my.salesforce.com',
    contentURL: 'https://holidaydev-pvhservicecloud.cs198.force.com/calvinklein',
    liveAgentURL: 'https://d.la2-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la2-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D050000008afk',
    deploymentID: '57205000000CaRb',
    buttonIds: '57305000000CaS0',
    serviceName: 'Calvin_Klein_Prioritized_Chat',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I7X000000GmadUAC_1747a7e2892',
    storageDomain: 'localhost', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/CK_Chat',
    enableLogging: true
};

// bot
// deploymentID: '57205000000CaRq',
// buttonIds: '57305000000CaSF',
// serviceName: 'Digital_Assistant',
// eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I050000004CAkEAM_1746aeec446',


// live chat
// deploymentID: '57205000000CaRb',
// buttonIds: '57305000000CaS0',
// serviceName: 'Calvin_Klein_Prioritized_Chat',
// eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I7X000000GmadUAC_1747a7e2892',

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
