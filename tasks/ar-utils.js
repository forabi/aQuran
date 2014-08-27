var regexps = {
    anyDiacritic: new RegExp('[\u0618\u0619\u061A\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0657\u0658\u06E1\u08F0\u08F1\u08F2\u064B.small\u064E.small\u08F1.small\u064F.small\u08F0.small\u064C.small\u0657.small\u0650.small\u064D.small\u0652.small2\u0650.small2\u064E.small2\u0657.urd]', 'gi')
}

module.exports.stripDiacritics = function(word) {
    return word.replace(regexps.anyDiacritic, '');
}