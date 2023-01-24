console.log('parent.document.domain');
console.log(parent.document.domain);
var storageDomainVar = '';
if( parent.document.domain.includes('izod') || parent.document.domain.includes('IZ') || parent.document.domain.includes('iz'))
{
    storageDomainVar = 'iz-b2cna-ps1.pvh.com';
}
else {
    storageDomainVar = 'vh-b2cna-ps1.pvh.com';
}
console.log(storageDomainVar);

 let eswOptions = {
    baseURL: 'https://pvhservicecloud--uat.my.salesforce.com',
    contentURL: 'https://uat-pvhservicecloud.cs35.force.com/pvh',
    liveAgentURL: 'https://d.la3-c1cs-ph2.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la3-c1cs-ph2.salesforceliveagent.com',
    orgID: '00D2g0000000UGP',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Partner_Brands_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LME0EAO_1752a94c4a7',
    storageDomain: storageDomainVar, //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/PB_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js?a=4' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})

// this is a test
