const getCurrenciesScript = "(function() { "
    ""
    "var currenciesResultObj = new Object();"
    ""
    "var bodyArea = document.getElementsByTagName('body')[0];"
    ""
    "var currenciesArea = bodyArea.getElementsByTagName('header')[0]"
    ".getElementsByClassName('sub-nav')[0]"
    ".getElementsByClassName('container')[0]"
    ".getElementsByTagName('ul')[0];"
    ""
    "var liItems = Array.from(currenciesArea.getElementsByTagName('li'));"
    "currenciesResultObj.currencies = liItems.map(e => {"
    "var link = e.getElementsByTagName('a')[0];"
    "var linkObj = new Object();"
    "linkObj.url = link.getAttribute('href');"
    "linkObj.title = link.getAttribute('title');"
    "return linkObj;"
    "});"
    ""
    "var updatedTimeElement = bodyArea.getElementsByTagName('main')[0]"
    ".getElementsByClassName('container')[0]"
    ".getElementsByClassName('row')[0]"
    ".getElementsByTagName('article')[0]"
    ".getElementsByTagName('h1')[0]"
    ".getElementsByTagName('small')[0];"
    "currenciesResultObj.updatedTime = updatedTimeElement.innerText;"
    ""
// Serialize interest data
    "var jsonString= JSON.stringify(currenciesResultObj);"
    ""
    "return ('<html>'+jsonString+'</html>'); })();";