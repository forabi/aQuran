app.service 'RecitationService', ['IDBStoreFactory', 'RESOURCES', (IDBStoreFactory, RESOURCES) ->
    properties = IDBStoreFactory "#{RESOURCES}/recitations.json",
        dbVersion: 1
        storeName: 'recitations'
        keyPath: 'subfolder'
        autoIncrement: no
        indexes: [
            (name: 'subfolder', unique: yes)
            (name: 'name')
            (name: 'bitrate')
        ]

    properties: properties
]