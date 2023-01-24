function getRecords(query) {
    let result = sforce.connection.query(query);
    let records = null;
    return result.getArray("records");
}

function getManagerSettings() {
    const query = `
        SELECT
            Id,
            MasterLabel,
            QualifiedAPIName,
            pcify__IsActive__c,
            pcify__MaskFields__c,
            pcify__MaskType__c,
            pcify__BatchStartDate__c,
            pcify__BatchEndDate__c,
            pcify__AuditAction__c,
            pcify__DetectionAction__c
        FROM pcify__Manager__mdt
        ORDER BY MasterLabel ASC, pcify__IsActive__c DESC`;
    return getRecords(query);
}

function getManagerSettingByObject(objectName) {
    const query = `
        SELECT
            Id,
            MasterLabel,
            QualifiedAPIName,
            pcify__IsActive__c,
            pcify__MaskFields__c,
            pcify__MaskType__c,
            pcify__BatchStartDate__c,
            pcify__BatchEndDate__c,
            pcify__AuditAction__c,
            pcify__DetectionAction__c
        FROM pcify__Manager__mdt
        WHERE MasterLabel = '${objectName}'
        LIMIT 1`;
    return getRecords(query);
}

function getPatterns() {
    const query = `
        SELECT
            Id, 
            MasterLabel, 
            QualifiedAPIName,
            pcify__Pattern__c,
            pcify__MaskCharacter__c,
            pcify__MaskType__c,
            pcify__Description__c,
            pcify__CreditCardPattern__c,
            pcify__IsActive__c,
            pcify__LuhnCheck__c,
            pcify__NegativePattern__c
        FROM pcify__DetectionPattern__mdt
        ORDER BY MasterLabel ASC, pcify__IsActive__c DESC`;
    return getRecords(query);
}

function getPatternByName(patternName) {
    const query = `
        SELECT
            Id, 
            MasterLabel, 
            QualifiedAPIName,
            pcify__Pattern__c,
            pcify__MaskCharacter__c,
            pcify__MaskType__c,
            pcify__Description__c,
            pcify__CreditCardPattern__c,
            pcify__IsActive__c,
            pcify__LuhnCheck__c,
            pcify__NegativePattern__c
        FROM pcify__DetectionPattern__mdt
        WHERE MasterLabel = '${patternName}'
        LIMIT 1`;
    return getRecords(query);
}

function getCreditCardsMaskedByObject(objectName) {
    let settings = [];
    let totalRecords = 0;
    const query = `
        SELECT
            Id,
            pcify__Summary__c,
            pcify__Category__c,
            pcify__Object__c,
            pcify__CreditCardsDetected__c
        FROM pcify__Log__c
        WHERE (pcify__Category__c = 'Record Masked' 
        OR pcify__Category__c = 'Record Reported' 
        OR pcify__Category__c = 'Record Deleted')
        AND pcify__Object__c = '${objectName}'`;

    settings = getRecords(query);

    if (!settings.length) {
        return 0;
    } else {
        settings.forEach((setting) => {
            totalRecords += Number(setting.pcify__CreditCardsDetected__c);
        });
    }
    return totalRecords;
}

function isFirstInstall() {
    let settings = [];
    const query = `
        SELECT
            Id,
            pcify__Summary__c,
            pcify__Category__c
        FROM pcify__Log__c
        WHERE pcify__Category__c = 'WelcomeMat'
        LIMIT 1`;

    settings = getRecords(query);
    // if we haven't shown the welcome mat yet
    if (!settings.length) {
        return true;
    } else {
        // we already showed it once, so don't show it again
        return false;
    }
}

function navigateToSetting(object) {
    const settingId = getManagerSettingByObject(object)[0].Id;
    return sforce.one.navigateToSObject(settingId);
}

function navigateToPattern(pattern) {
    const patternId = getPatternByName(pattern)[0].Id;
    return sforce.one.navigateToSObject(patternId);
}

function refresh() {
    return document.location.reload(true);
}

function createLog(category) {
    Visualforce.remoting.Manager.invokeAction(
        vf_context['remote_CreateLog'],
        category,
        function(result, event) {
            if (event.status) {
                console.log('result: ', result);
            } else if (event.type === 'exception') {
                console.error('responseErrors exception: ', event.message);
            } else {
                console.error('responseErrors: ', event.message);
            }
        },
        {escape: false}
    );
}

function executeBatch(objectName) {
    Visualforce.remoting.Manager.invokeAction(
        vf_context['remote_ExecuteBatch'],
        objectName,
        function(result, event) {
            if (event.status) {
                console.log('result: ', result);
            } else if (event.type === 'exception') {
                console.error('responseErrors exception: ', event.message);
            } else {
                console.error('responseErrors: ', event.message);
            }
        },
        {escape: false}
    );
}

function deleteLogs() {
    Visualforce.remoting.Manager.invokeAction(
        vf_context['remote_DeleteLogs'],
        function(result, event) {
            if (event.status) {
                console.log('result: ', result);
            } else if (event.type === 'exception') {
                console.error('responseErrors exception: ', event.message);
            } else {
                console.error('responseErrors: ', event.message);
            }
        },
        {escape: false}
    );
}
