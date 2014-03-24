{
  name: "aQuran"
  description: "A full-featured Quran app with multiple translations and recitations"
  version: "1"
  manifest_version: 2
  default_locale: "en"
  developer:
    name: "Muhammad Fawwaz Orabi"
    url: "http://j.mp/forabi"
  locales:
    ar:
      name: "القرآن الكريم"
      description: "اقرأ القرآن مع التفاسير واستمع لتلاوات بصوت العديد من المقرئين"
      developer:
        name: "محمد فواز عرابي"
  permissions:
    storage:
      description: "Required to store application databases, including translations."
  icons:
    '16' : "images/icon-16.png"
    '24' : "images/icon-24.png"
    '48' : "images/icon-48.png"
    '64' : "images/icon-64.png"
    '72' : "images/icon-72.png"
    '96' : "images/icon-96.png"
    '128': "images/icon-128.png"
  launch_path: "/index.html"
  app:
    background:
      scripts: [
        "launcher.js"
        "scripts/chromereload.js"
      ]
}