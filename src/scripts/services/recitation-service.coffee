app.service 'RecitationService', ['IDBStoreFactory', (IDBStoreFactory) ->
    IDBStoreFactory 'resources/recitations.json',
        dbVersion: 1
        storeName: 'recitations'
        storePrefix: ''
        keyPath: 'id'
        autoIncrement: no
        indexes: [
            (name: 'id', unique: yes)
            # (name: 'page_id')
            # (name: 'sura_id')
            # (name: 'aya_id')
            # (name: 'standard')
        ]

    # getRecitations: () ->
    #     $http.get 'resources/recitations.json'
    #     .then (response) ->
    #         $log.debug 'Available recitations:', response.data
    #         response.data
    #     .catch (response) ->
    #         $log.error 'Error retrieving reciations, got response:', response
]