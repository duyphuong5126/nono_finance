const getInterestScript = "(function() { "
    ""
    "var interestObj = new Object();"
    ""
    "var interestArea = document.getElementsByTagName('body')[0]"
    ".getElementsByTagName('main')[0]"
    ".getElementsByClassName('container')[0]"
    ".getElementsByClassName('row')[0]"
    ".getElementsByTagName('article')[0];"
    ""
// Start getting counter interest data
// id: lai_suat_tiet_kiem_tai_quay
    "var counterInterestTable = interestArea.getElementsByTagName('section')[0]"
    ".getElementsByClassName('table-responsive')[0]"
    ".getElementsByTagName('table')[0];"
    ""
// Getting counter terms
    "var counterTerms = Array.from(counterInterestTable"
    ".getElementsByTagName('thead')[0]"
    ".getElementsByTagName('tr')[1]" // second row contains terms
    ".getElementsByTagName('th')).map(item => item.innerText);"
    "interestObj.counterTerms = counterTerms;"
    ""
// Getting counter interest rates
    "var counterInterestRows = Array.from(counterInterestTable"
    ".getElementsByTagName('tbody')[0]"
    ".getElementsByTagName('tr'));"
    ""
    "interestObj.counterInterestRates = counterInterestRows.map(row => {"
    "var bankObj = new Object();"
    "bankObj.bankName = row.getElementsByClassName('text-left')[0].innerText;"
    "var rowItems = Array.from(row.getElementsByClassName('text-right'));"
    "bankObj.interestRates = rowItems.map(e => e.innerText);"
    "return bankObj;"
    "});"
// End getting counter interest data
// Start getting online interest data
// id: lai_suat_tiet_kiem_online
    "var onlineInterestTable = interestArea.getElementsByTagName('section')[1]"
    ".getElementsByClassName('table-responsive')[0]"
    ".getElementsByTagName('table')[0];"
    ""
// Getting online terms
    "var onlineTerms = Array.from(onlineInterestTable"
    ".getElementsByTagName('thead')[0]"
    ".getElementsByTagName('tr')[1]" // second row contains terms
    ".getElementsByTagName('th')).map(item => item.innerText);"
    "interestObj.onlineTerms = onlineTerms;"
    ""
// Getting online interest rates
    "var onlineInterestRows = Array.from(onlineInterestTable"
    ".getElementsByTagName('tbody')[0]"
    ".getElementsByTagName('tr'));"
    ""
    "interestObj.onlineInterestRates = onlineInterestRows.map(row => {"
    "var bankObj = new Object();"
    "bankObj.bankName = row.getElementsByClassName('text-left')[0].innerText;"
    "var rowItems = Array.from(row.getElementsByClassName('text-right'));"
    "bankObj.interestRates = rowItems.map(e => e.innerText);"
    "return bankObj;"
    "});"
// End getting online interest data
    ""
// Serialize interest data
    "var jsonString= JSON.stringify(interestObj);"
    ""
    "return ('<html>'+jsonString+'</html>'); })();";
