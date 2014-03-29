{
    name: 'aQuran'
    description: 'A full-featured Quran app with multiple translations and recitations'

    version: '1'
    released: new Date()
    manifest_version: 2

    default_locale: 'en'

    developer:
        name: 'Muhammad Fawwaz Orabi'
        url: 'http://j.mp/forabi'

    permissions:
        storage:
            description: 'Required to store application databases, including translations'
        systemXHR:
            description: 'Required to communicate with Al-Fanous web service when performing an online search'

    icons:
        '16' : 'icons/icon-16.png'
        '24' : 'icons/icon-24.png'
        '48' : 'icons/icon-48.png'
        '64' : 'icons/icon-64.png'
        '72' : 'icons/icon-72.png'
        '96' : 'icons/icon-96.png'
        '128': 'icons/icon-128.png'

    launch_path: '/index.html'

    app:
        background:
          scripts: [
            'launcher.js'
            'scripts/chromereload.js'
          ]

    locales:
        ar:
            name: 'القرآن الكريم'
            description: 'اقرأ القرآن مع التفاسير واستمع لتلاوات بصوت العديد من المقرئين'
            developer: name: 'محمد فواز عرابي'
            permissions:
                storage: description: 'مطلوب لتخزين قواعد بيانات التطبيق، متضمنةً التفاسير والترجمات'
                systemXHR: description: 'مطلوب للاتصال بخدمة الفانوس عند البحث عبر الإنترنت'

}