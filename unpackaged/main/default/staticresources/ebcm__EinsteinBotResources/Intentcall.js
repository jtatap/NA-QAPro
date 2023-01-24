if (!window.loaded) {
    window.loaded = true;

    window.addEventListener('ebcm__progress_flow', event => {
        let element = document.getElementsByClassName('chasitorText')[0];
        if (event.detail) {
            if (!element) {
                // element = window.userInputContent[2];
                element = window.userInputContent.find(e => e.nodeName === 'TEXTAREA');
            }
            element.value = event.detail;
            element.dispatchEvent(new KeyboardEvent('keydown', { 'keyCode': 13 }));
            element.value = '';
            setTimeout(() => {
                let messages = document.getElementsByTagName('ebcm-einstein-bot-chat-message');
                if (messages.length === 0) {
                    messages = document.getElementsByTagName('c-einstein-bot-chat-message');
                }
                messages[messages.length - 1].remove();
            }, 100);
        }
    });

    /** 
     *Event listeners for enabling and disabling input
    */
    window.addEventListener('ebcm__blockinput', (e) => {
        window.userInputContent = [];
        let userInputParent = document.getElementsByClassName('chasitorControls');
        userInputParent[0].childNodes.forEach(element => {
            window.userInputContent.push(element);
        });
        userInputParent[0].innerHTML = '<div class="chatInputBoxDisabled"">' + e.detail.msg + '</div>';
    });
    window.addEventListener('ebcm__allowinput', (e) => {
        let userInputParent = document.getElementsByClassName('chasitorControls');
        userInputParent[0].childNodes.forEach((s) => {
            userInputParent[0].removeChild(s);
        });
        window.userInputContent.forEach(element => {
            userInputParent[0].appendChild(element);
        });
    });

    window.addEventListener('ebcm__newElement', event => {
        let messages = document.getElementsByTagName('ebcm-einstein-bot-chat-message');
        if (messages.length === 0) {
            messages = document.getElementsByTagName('c-einstein-bot-chat-message');
        }
        messages[messages.length - 1].scrollIntoView(false);
    });
}