console.log(parent.document.domain);
var storageDomainVar = '';
if( parent.document.domain.includes('izod') || parent.document.location.href.includes('IZ') || parent.document.domain.includes('iz'))
{
    storageDomainVar = 'iz-b2cna-ps1.pvh.com';
}
else {
    storageDomainVar = 'vh-b2cna-ps1.pvh.com';
}
console.log(storageDomainVar);

 let eswOptions = {
    baseURL: 'https://pvhservicecloud--qapro.my.salesforce.com',
    contentURL: 'https://qapro-pvhservicecloud.cs59.force.com/pvh',
    liveAgentURL: 'https://d.la1-c1cs-ia4.salesforceliveagent.com',
    liveAgentContentURL: 'https://d.la1-c1cs-ia4.salesforceliveagent.com',
    orgID: '00D2C000000Cmsr',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Partner_Brands_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LME0EAO_1752a94c4a7',
    storageDomain: 'neuraflash.com', //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/PB_Chat',
    enableLogging: true
};

$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js?a=43' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})


