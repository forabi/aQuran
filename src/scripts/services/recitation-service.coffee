app.service 'RecitationService', ['IDBStoreFactory', (IDBStoreFactory) ->
    properties = IDBStoreFactory 'resources/recitations.json',
        dbVersion: 1
        storeName: 'recitations'
        storePrefix: ''
        keyPath: 'subfolder'
        autoIncrement: no
        indexes: [
            (name: 'subfolder', unique: yes)
            (name: 'bitrate')
        ]

    properties: properties
]