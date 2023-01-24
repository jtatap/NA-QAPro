
console.log('parent.document.domain');
console.log(parent.document.domain);
var storageDomainVar = '';
if( parent.document.domain.includes('izod') || parent.document.domain.includes('IZ') || parent.document.domain.includes('iz'))
{
    storageDomainVar = 'izod.partnerbrands.com';
}
else {
    storageDomainVar = 'vanheusen.partnerbrands.com';
}
console.log(storageDomainVar);

let eswOptions = {
    baseURL: 'https://pvhservicecloud.my.salesforce.com',
    contentURL: 'https://help.vanheusen.partnerbrands.com/',
    liveAgentURL: 'https://d.la1-c1-ia5.salesforceliveagent.com',
    liveAgentContentURL: 'https://c.la1-c1-ia5.salesforceliveagent.com',
    orgID: '00D1U000000xmv4',
    deploymentID: '5723t000000D4dL',
    buttonIds: '5733t0000008t5U',
    serviceName: 'Partner_Brands_Bot',
    eswLiveAgentDevName: 'EmbeddedServiceLiveAgent_Parent04I3t000000LME0EAO_1752a94c4a7',
    storageDomain: storageDomainVar, //THE DOMAIN NAME OF THE WEBSITE HOSTING THE CHAT WINDOW
    resourceBase: '/resource/PB_Chat',
    enableLogging: true
};
$.getScript(eswOptions.contentURL + eswOptions.resourceBase + '/js/digitalAssistant-botLoader.js' + (eswOptions.enableLogging ? '?' + Date.now() : ''), function( data, textStatus, jqxhr ){ initBot(eswOptions)})
