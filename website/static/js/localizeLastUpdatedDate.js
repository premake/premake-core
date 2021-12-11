function waitForElementToChange(selector) {
    return new Promise(resolve => {
        const observer = new MutationObserver(() => {
            const element = document.querySelector(selector)
            if (element) {
                resolve(element);
                observer.disconnect();
            }
        });

        observer.observe(document.body, {
            characterData: true,
            childList: true,
            subtree: true
        });
    });
}

function localizeTimeElement(element) {
    if (element instanceof HTMLTimeElement && element.hasAttribute('datetime')) {
        const iso8601 = element.getAttribute('datetime');
        const date = new Date(iso8601);
        element.textContent = date.toLocaleDateString();
    }
}

(async() => {
    while(true) {
        const selector = '.theme-last-updated time';

        // if it exists then take it
        let timeElement = document.querySelector(selector);
        localizeTimeElement(timeElement);

        // wait for element to change (or appear if it didn't exist)
        timeElement = await waitForElementToChange(selector);
        localizeTimeElement(timeElement);
    }
})();
