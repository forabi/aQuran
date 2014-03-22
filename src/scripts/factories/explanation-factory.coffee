app.factory 'ExplanationFactory', ['ExplanationService', (ExplanationService) ->
    (explanation, gid) ->
        ExplanationService.load explanation
        .then (database) ->
            database.findOne gid: gid
            .exec()
]