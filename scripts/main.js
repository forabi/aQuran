var app;app=angular.module("quran",["ngSanitize","ngStorage","ionic","audioPlayer"]),app.constant("API","http://www.alfanous.org/jos2"),app.constant("EveryAyah","http://www.everyayah.com/data"),app.run(["$rootScope","AppCacheManager","Preferences","$window",function(e,t,r,a){return e.online=a.navigator.onLine,e.options=r,a.addEventListener("online",function(){return e.online=!0,e.$apply()}),a.addEventListener("offline",function(){return e.online=!1,e.$apply()})}]),app.config(["$stateProvider","$urlRouterProvider","$locationProvider","$logProvider",function(e,t){return e.state("reader",{url:"/reader/:current?highlight&scrollTo",templateUrl:"views/reader.html",controller:"ReadingController"}).state("aya",{url:"/aya/:gid?highlight",templateUrl:"views/aya.html",controller:"AyaController"}).state("navigate",{url:"/navigate",templateUrl:"views/navigation.html",controller:"NavigationController"}).state("search",{url:"/search?query",templateUrl:"views/search.html",controller:"SearchController"}).state("preferences",{url:"/preferences",templateUrl:"views/preferences.html",controller:"PreferencesController"}).state("themes",{templateUrl:"views/themes.html",controller:"PreferencesController"}).state("sura-name",{templateUrl:"views/sura_name.html",controller:"PreferencesController"}).state("explanations",{url:"/explanations",templateUrl:"views/explanations.html",controller:"ExplanationsController"}).state("recitations",{url:"/recitations",templateUrl:"views/recitations.html",controller:"RecitationsController"}).state("about",{url:"/about",templateUrl:"views/about.html",controller:["$http","$scope",function(e,t){return e.get("manifest.webapp",{headers:"application/json",cache:!0}).then(function(e){return t.info=e.data})}]}),t.otherwise("/reader/1")}]);
app.controller("AyaController",["$scope","ContentService","$stateParams","$log",function(e,t,n){return e.progress={status:"init"},e.aya={gid:Number(n.gid||1)},t.then(function(t){return t.findOne(e.aya).exec().then(function(t){return e.aya=t,e.progress.status="ready"})})}]);
app.controller("ExplanationsController",["$scope","$log","ExplanationService",function(n,e,a){return n.explanations={enabled:[],available:[]},a.properties.then(function(a){var i;return i=function(n){return _.chain(n).sortBy(["language","name"]).value()},n.toggle=function(e){return n.isEnabled(e)?_.remove(n.explanations.enabled,{id:e.id}):n.explanations.enabled.push(e),n.options.explanations.ids=_.pluck(n.explanations.enabled,"id")},n.isEnabled=function(e){return _.contains(n.options.explanations.ids,e.id)},a.find().exec().then(function(a){return e.debug(a),n.explanations.available=i(a),n.explanations.enabled=_.filter(n.explanations.available,function(e){return _.contains(n.options.explanations.ids,e.id)})})})["catch"](function(n){return e.error(n)})}]);
app.controller("NavigationController",[function(){}]);
app.controller("PreferencesController",["$scope","$log","ExplanationService",function(e){return e.sura_names=[{value:"sura_name",name:"Arabic",example:"الفاتحة"},{value:"sura_name_en",name:"English",example:"The Opening"},{value:"sura_name_romanization",name:"Romanized",example:"Al-Fatiha"}],e.themes=[{id:"light",name:"Light"},{id:"stable",name:"Stable"},{id:"positive",name:"Positive"},{id:"calm",name:"Calm"},{id:"balanced",name:"Balanced"},{id:"energized",name:"Energized"},{id:"assertive",name:"Assertive"},{id:"royal",name:"Royal"},{id:"dark",name:"Dark"}]}]);
app.controller("ReadingController",["$rootScope","$scope","$state","$stateParams","$log","ContentService","Preferences",function(r,e,t,n,o,s){var i,u,a;return e.playlist=[],e.pages=[],e.view=_.defaults(n,e.options.reader.view),e.progress={status:"init",total:0,current:0},e.$watch("scrollTo",function(r,t){return r>t?e.loadMore():void 0}),a=function(r){return _.chain(r).map(function(r,t){return e.playlist.push(r.recitation),r.index=t,r}).value()},u=function(){var t;return t={},t[e.view.type]=e.view.current,s.then(function(r){return r.find(t).exec()}).then(a).then(function(t){return o.debug("Content ready",t),r.title=t[0].sura_name,e.progress.status="ready",t},i,function(r){return e.progress.message=r})},e.loadMore=function(){return e.view.current++,u().then(function(r){return e.pages.push(r),e.$broadcast("scroll.infiniteScrollComplete")})},u().then(function(r){return e.pages.push(r),e.options.first_time=!1,e.scrollTo=n.scrollTo}),i=function(r){return e.progress.status="error",e.error=r,o.error("Error",r)}}]);
app.controller("RecitationsController",["$scope","$log","RecitationService",function(n,e,t){return n.recitations=[],t.properties.then(function(e){return e.find().exec().then(function(e){return n.recitations=_.chain(e).uniq(!0,"name").value()})})["catch"](function(n){return e.error(n)})}]);
app.controller("SearchController",["$scope","$rootScope","$state","$log","$stateParams","SearchService","APIService",function(e,r,s,t,u,n,o){var c;return e.progress={status:"init",total:0,current:0,message:""},e.search={query:u.query||"",suggestions:[],results:[],execute:function(r){return null==r&&(r=e.search.query),r?(e.progress.status="searching",e.search.results=[],n.search(r).then(function(r){return t.debug("Found "+r.length+" results:",r),e.search.results=r,r})["catch"](function(e){if("NO_RESULTS"===e)return t.debug("No results found, going to fetch suggestions"),o.suggest(r);throw e}).then(function(r){return e.search.suggestions=r||[],t.debug("Suggestions:",e.search.suggestions),r}).then(function(){return e.progress.status="ready"})["catch"](c)):void 0}},e.search.execute(),c=function(r){return e.progress.status="error",e.error=r,t.error("Error:",r),e.$apply()}}]);
app.directive("autoDirection",["LocalizationService",function(t){return{restrict:"ACE",link:function(r,i,e){return e.$observe("autoDirection",function(r){return r||(r=i.text()),i.attr("dir",t.isRTL(r)?"rtl":"ltr")})}}}]);
app.directive("colorize",["ArabicService","$timeout","$log",function(s,a){var n;return n=function(a,n,r,e){var i;return null==e&&(e=!0),n&&r&&("string"==typeof r&&(r=s.getRegExp(r)),n=n.replace(r,"<span class='highlighted'>$1</span>")),i=e?a.split(/\s+/g).map(function(s){return"<span class='layers'> <span class='diacritics'>"+s+"</span> <span class='quranic-signs'>"+s+"</span> <span class='letters'>"+s+"</span> </span>"}).join(" "):a,n&&(i="<span class='layers'> <span class='original'>"+n+"</span> <span class='overlay'>"+i+"</span> </span>"),i},{restrict:"A",replace:!0,link:function(s,r,e){return a(function(){var s,a,i,l;return s=!1,e.colorize&&"false"!==e.colorize&&(s=!0),l=e.colorizeText,a=e.highlight,i=e.searchText,l=n(l,i,a,s),r.html(l)})}}}]);
app.directive("emphasize",["$timeout",function(e){return{restrict:"A",replace:!0,link:function(r,t,n){var i;return i=function(e,r){var t;return t=new RegExp("("+r+")","gi"),console.log(e.replace(t,"<em>$1</em>")),e.replace(t,"<em>$1</em>")},e(function(){var e;return e=n.emphasize,t.html(i(t.text(),e))})}}}]);
app.directive("scrollTo",["$location","$anchorScroll","$timeout",function(r,n,o){var t;return t=function(n){return n?r.hash(""+n):void 0},{restrict:"A",replace:!1,link:function(r,c,e){return e.$observe("scrollTo",function(c){return r.$watch("$location.hash",function(){return o(n)}),t(c)})}}}]);
app.factory("AudioSrcFactory",["$sce","EveryAyah","Preferences","RecitationService","$q","CacheService","$log",function(n,t,e,r,u,i,o){var a,c,d,f;return f=function(n,t){for(;t>0;)n+=n,t--;return n},a=function(n){return Math.max.apply(Math,n)},c=function(n){return Math.min.apply(Math,n)},d=function(n,t){return null==t&&(t="3"),n=f("0",t)+n,n.substr(n.length-3)},function(f,h){var s,l,p;return f=d(f),h=d(h),e.audio.auto_quality&&navigator.mozConnection?(s=function(){var n,t;return n=i.get("audio:"+e.audio.recitation.name+":quality"),n?u.when(n):(t=function(n){var t,r,u;return t=_.clone(n),r=e.connection.auto?navigator.mozConnection.bandwidth:e.connection.bandwidth,o.debug("Bandwidth:",r),o.debug("Available:",t),u=function(){switch(r){case 1/0:return a(t);default:return _.remove(t,function(n){return 8*n/1024>r}),a(t)}}(),0===t.length?c(n):u},r.properties.then(function(n){return n.find().where("name").is(e.audio.recitation.name).exec()}).then(function(n){return o.debug(n),n.map(function(n){return Number(n.subfolder.match(/(\d+)kbps/i)[1])})}).then(t).then(function(n){return i.put("audio:"+e.audio.recitation.name+":quality",n),n}))},s().then(function(r){var u;return u=e.audio.recitation.subfolder.match(/^(.+)_\d+kbps/i)[1],p=""+u+"_"+r+"kbps",l=""+t+"/"+p+"/"+f+h+".mp3",{src:n.trustAsResourceUrl(l),type:"audio/mp3"}})):(p=e.audio.recitation.subfolder,l=""+t+"/"+p+"/"+f+h+".mp3",u.when({src:n.trustAsResourceUrl(l),type:"audio/mp3"}))}}]);
app.factory("ExplanationFactory",["ExplanationService",function(n){return function(t,e){return n.load(t).then(function(n){return n.findOne({gid:e}).exec()})}}]);
var __slice=[].slice;app.factory("IDBStoreFactory",["$q","$http","$log","QueryBuilder","Preferences",function(e,r,n,t,a){return function(n,o){var s,u,i,f,c;return o=_.defaults(o,{dbVersion:1,storePrefix:"",transforms:[],transformResponse:function(e){return e.data}}),s=e.defer(),i=function(){return s.notify({action:"STORE.FETCHING",data:{storeName:o.storeName}}),r.get(n,{cache:!0}).then(o.transformResponse)},f=function(r){var n;return s.notify({action:"STORE.INSERTING",data:{storeName:o.storeName}}),n=e.defer(),c.putBatch(r,function(){return n.resolve(c)},function(e){return n.reject(e)}),a[""+o.storeName+"-version"]=o.dbVersion,n.promise},u=function(e){return{find:function(){var r,n;return r=1<=arguments.length?__slice.call(arguments,0):[],(n=t(e,o.transforms)).find.apply(n,r)},findOne:function(){var r,n;return r=1<=arguments.length?__slice.call(arguments,0):[],(n=t(e,o.transforms)).findOne.apply(n,r)},findById:function(){var r,n;return r=1<=arguments.length?__slice.call(arguments,0):[],(n=t(e,o.transforms)).findById.apply(n,r)},findOneById:function(){var r,n;return r=1<=arguments.length?__slice.call(arguments,0):[],(n=t(e,o.transforms)).findOneById.apply(n,r)},where:function(){var r,n;return r=1<=arguments.length?__slice.call(arguments,0):[],(n=t(e,o.transforms)).where.apply(n,r)}}},c=new IDBStore(o),c.onStoreReady=function(){return Number(a[""+o.storeName+"-version"]===o.dbVersion)?s.resolve(c):i().then(f).then(s.resolve)},c.onError=function(e){return s.reject(e)},s.promise.then(u)}}]);
app.factory('QueryBuilder', [
  '$q', '$log', function($q, $log) {
    return function(db, transforms) {
      var exec, find, findById, findOne, findOneById, limit, sort, transform, where, _exclude_lower, _exclude_upper, _index, _limit, _lower, _make_range, _one, _order, _parse_bounds, _transforms, _upper;
      _index = void 0;
      _limit = void 0;
      _lower = void 0;
      _upper = void 0;
      _exclude_lower = false;
      _exclude_upper = false;
      _order = 'ASC';
      _one = false;
      _transforms = transforms || [];
      _parse_bounds = function(range) {
        if (range instanceof Array) {
          _lower = range[0];
          return _upper = range[1] || null;
        } else {
          _lower = range;
          return _upper = _lower;
        }
      };
      _make_range = function() {
        var err;
        if (!_lower && !_upper) {
          return void 0;
        } else {
          try {
            return db.makeKeyRange({
              lower: Math.min(_lower, _upper),
              excludeLower: _exclude_lower,
              upper: Math.max(_lower, _upper),
              excludeUpper: _exclude_upper
            });
          } catch (_error) {
            err = _error;
            return _lower;
          }
        }
      };
      exec = function() {
        var deferred, error, options, success;
        deferred = $q.defer();
        success = function(result) {
          return deferred.resolve(result);
        };
        error = function(err) {
          return deferred.reject(err);
        };
        options = {
          index: _index,
          keyRange: _make_range(),
          order: _order,
          onError: error
        };
        db.query(success, options);
        return deferred.promise.then(function(results) {
          if (_transforms.length) {
            return $q.all(results.map(function(result) {
              var fn, _i, _len;
              for (_i = 0, _len = _transforms.length; _i < _len; _i++) {
                fn = _transforms[_i];
                result = fn(result);
              }
              return result;
            }));
          } else {
            return results;
          }
        }).then(function(results) {
          if (_one) {
            results = results[0] || null;
          }
          return results;
        });
      };
      transform = function(fn) {
        _transforms.push(fn);
        return {
          exec: exec
        };
      };
      limit = function(limit) {
        _limit = limit;
        return {
          limit: limit,
          transform: transform,
          exec: exec
        };
      };
      sort = function(sort) {
        if (sort.match(/^des/gi || Number(sort) === -1)) {
          _order = 'DESC';
        }
        return {
          limit: limit,
          transform: transform,
          exec: exec
        };
      };
      where = function(index) {
        var between, from, is_;
        _index = index;
        between = function(lower, upper) {
          _lower = lower;
          _upper = upper;
          _exclude_lower = true;
          _exclude_upper = true;
          return {
            limit: limit,
            sort: sort,
            transform: transform,
            exec: exec
          };
        };
        from = function(lower) {
          _lower = lower;
          return {
            limit: limit,
            sort: sort,
            transform: transform,
            exec: exec,
            to: function(upper) {
              _upper = upper;
              return {
                limit: limit,
                sort: sort,
                transform: transform,
                exec: exec
              };
            }
          };
        };
        is_ = function(value) {
          if (value) {
            _lower = value;
            _upper = value;
            return {
              exec: exec
            };
          } else {
            return {
              exec: exec,
              from: from,
              between: between,
              transform: transform
            };
          }
        };
        return {
          between: between,
          is: is_,
          from: from,
          limit: limit,
          exec: exec,
          transform: transform
        };
      };
      find = function(query, range) {
        var keys;
        switch (false) {
          case !(!query || typeof query === 'string'):
            _index = query;
            _parse_bounds(range);
            return {
              exec: exec,
              where: where,
              limit: limit,
              sort: sort,
              transform: transform
            };
          case typeof query !== 'object':
            keys = _.keys(query);
            if (_.include(keys, 'limit')) {
              limit(query.limit);
              _.pull(keys, 'limit');
            }
            if (_.include(keys, 'sort')) {
              sort(query.sort);
              _.pull(keys, 'sort');
            }
            if (keys.length > 1) {
              throw 'QueryBuilder is limited to one key per query';
            }
            _index = keys[0];
            range = query[_index];
            _parse_bounds(range);
            return {
              exec: exec,
              limit: limit,
              sort: sort,
              transform: transform
            };
        }
      };
      findOne = function(query) {
        _one = true;
        if (query) {
          delete query.limit;
        }
        limit(1);
        return find(query);
      };
      findById = function(id, query, range) {
        _index = 'id';
        return find(query, range);
      };
      findOneById = function(id, query) {
        _index = 'id';
        return find(query);
      };
      return {
        transform: transform,
        find: find,
        findOne: findOne,
        findById: findById,
        findOneById: findOneById,
        where: where
      };
    };
  }
]);

app.filter("arabicNumber",["ArabicService",function(r){return function(e){return r.Numbers.Array.forEach(function(r,n){return e=e.replace(new RegExp(n.toString,"g"),n.toLocaleString())}),e}}]);
app.filter("progress",[function(){var e;return e={"STORE.FETCHING":"Loading ${storeName} database from the server...","STORE.INSERTING":"Storing ${storeName} for offline use..."},function(r){return _.template(e[r.action],r.data)}}]);
app.service("APIService",["API","$http","$log",function(r,e,t){var n;return n=function(r){if(r.data.error.code===!0)throw"API Error";return r},{query:function(t){return e.get(r,{cache:!0,params:_.defaults(t,{action:"search",unit:"aya",traduction:1,fuzzy:"True"})})},suggest:function(u){return e.get(r,{params:{query:u,action:"suggest",unit:"aya"}}).then(n).then(function(r){var e;return t.debug("Response for suggestions",r),e=[],_(r.data.suggest).each(function(r,t){return r.forEach(function(r){return e.push({string:u.replace(t,r),replace:t,"with":r})})}),_.remove(e,{string:u}),e})}}}]);
app.service("AppCacheManager",["$window","$rootScope","$log",function(n,o,e){return n.applicationCache.onchecking=function(n){return e.info("AppCache Checking...",n)},n.applicationCache.onupdateready=function(n){return e.info("AppCache Update Ready",n)},n.applicationCache.onobsolete=function(n){return e.info("AppCache Obsolete",n)},n.applicationCache.ondownloading=function(n){return e.info("AppCache Downloading...",n)},n.applicationCache.onprogress=function(n){return e.info("AppCache in progress",n)},n.applicationCache.onerror=function(n){return e.error("AppCache Error",n)},n.applicationCache.oncached=function(n){return e.info("AppCache Cached",n)},n.applicationCache}]);
app.service("ArabicService",[function(){var u,e,a,l,E,r;return u=/[\u060c-\u06fe\ufb50-\ufefc]/g,e="([ًࣰًٌࣱٍࣲؘَؙُؚِّْٗ٘ۡ.smallَ.smallࣱ.smallُ.smallࣰ.smallٌ.smallٗ.smallِ.smallٍ.smallْ.small2ِ.small2َ.small2ٗ.urd])",E=/[\u0615\u0617\u065C\u0670\u06D6\u06D7\u06D8\u06D9\u06DA\u06DB\u06DC\u06DD\u06DE\u06DF\u06E0\u06E2\u06E3\u06E4\u06E5\u06E6\u06E7\u06E8\u06E9\u06EA\u06EB\u06EC\u06ED\u0670.isol\u0670.medi\u06E5.medi\u06E6]/,a="([آإأءئؤاىو])",l=["٠","١","٢","٣","٤","٥","٦","٧","٨","٩"],r=[{id:"alefHamzas",replace:/[أإآا]/g,"with":"[أإآا]"},{id:"alefMadda",replace:/آ|(?:ءا)/g,"with":"(?:آ|(?:ءا))"}],{getRegExp:function(u){return r.forEach(function(e){return u=u.replace(e.replace,e["with"])}),new RegExp("("+u+")","g")},Alphabet:{RegExp:u},Diacritics:{RegExp:new RegExp(e,"g"),String:e},Hamzas:{String:a,RegExp:new RegExp(a,"g")},Numbers:{Array:l},Quranic:{Sign:{RegExp:E}}}}]);
app.service("CacheService",["$cacheFactory",function(e){return e("CacheService")}]);
app.service("ContentService",["IDBStoreFactory","ExplanationFactory","AudioSrcFactory","Preferences","$q","$log",function(n,e,r,a,t,i){return n("resources/quran.json",{dbVersion:3,storeName:"ayas",keyPath:"gid",autoIncrement:!1,indexes:[{name:"gid",unique:!0},{name:"page_id"},{name:"sura_id"},{name:"aya_id"},{name:"standard"}],transforms:[function(n){return n.sura_name=n[a.reader.sura_name],n.text=function(){switch(!1){case!!a.reader.diacritics:return n.standard;case!(a.reader.standard_text&&a.reader.diacritics):return n.standard_full;default:return n.uthmani}}(),n},function(n){return a.explanations.enabled?t.all(a.explanations.ids.map(function(r){return e(r,n.gid)})).then(function(e){return n.explanations=e,n}):t.when(n)},function(n){return n.then(function(n){return a.audio.enabled?r(n.sura_id,n.aya_id).then(function(e){return n.recitation=e,n}):n})}]})["catch"](function(n){return i.error(n)})}]);
app.service("ExplanationService",["IDBStoreFactory","$log",function(n,e){var t,r;return t=[],r=n("resources/translations.json",{dbVersion:2,storeName:"explanations",keyPath:"id",autoIncrement:!1,indexes:[{name:"id",unique:!0},{name:"country"},{name:"language"}]}),{properties:r,load:function(a){return t["trans:"+a]||(t["trans:"+a]=r.then(function(n){return n.findOne({id:a}).exec()}).then(function(e){return n("resources/translations/"+e.file,{transformResponse:function(n){return n.data.split(/\n/g).map(function(n,e){return{gid:e+1,text:n}})},dbVersion:1,storeName:a,keyPath:"gid",autoIncrement:!1,indexes:[{name:"gid",unique:!0}],transforms:[function(n){return _.extend(n,e)}]})}).then(function(n){return e.debug("Store ready for explanation "+a),n})["catch"](function(n){return e.error(n)}))}}}]);
app.service("LocalizationService",function(){var n,e;return e=function(n){return n.replace(/@\w+/,"")},n=function(n,e){var r;return r=n.match(new RegExp(e,"g")),r?r.length:0},{isRTL:function(r){var t;return r=e(r),t=n(r,"[\\u060C-\\u06FE\\uFB50-\\uFEFC]"),100*t/r.length>20}}});
app.service("NavigationService",[function(){return{go:function(a){return{aya_id:a.match(/(?!aya\s*(\d+))|\d+\W(\d+)/gi)[1],page_id:a.match(/page\s*(\d+)/gi)[1],sura_id:a.match(/(?!surah*\s*(\d+))|(d+)\W\d+/gi)[1],sura_name:a.match(/surah*\s*(\D+)/gi)[1]}}}}]);
app.service("Preferences",["$localStorage",function(a){var e;return e={first_time:!0,theme:"balanced",search:{history:[],max_history:10,online:{enabled:!1,prompt:!0}},explanations:{enabled:!0,ids:["ar.muyassar","en.ahmedali"]},reader:{arabic_text:!0,standard_text:!1,diacritics:!0,view:{type:"page_id",current:1,total:604},colorized:!0,aya_mode:"uthmani",sura_name:"sura_name_romanization",sura_name_transliteration:!0},audio:{recitation:{subfolder:"Abdul_Basit_Murattal_64kbps",name:"Abdul Basit Murattal",bitrate:"64kbps"},auto_quality:!0,enabled:!0},connection:{bandwidth:.25,auto:!1}},a.$default(e)}]);
app.service("RecitationService",["IDBStoreFactory",function(e){var r;return r=e("resources/recitations.json",{dbVersion:1,storeName:"recitations",keyPath:"subfolder",autoIncrement:!1,indexes:[{name:"subfolder",unique:!0},{name:"name"},{name:"bitrate"}]}),{properties:r}}]);
app.service("SearchService",["APIService","ContentService","ArabicService","Preferences","$log","$http","$q",function(e,r,n,i,t,a,o){var c,s,u,f;return c=void 0,u=function(){return c=a.get("resources/search.json",{cache:!0}).then(function(e){return e.data}).then(function(e){var r,n;return n=o.defer(),r=new Nedb,r.insert(e,function(e){if(e)throw e;return n.resolve(r)}),n.promise})},s=function(e){var n;return n=o.defer(),r.then(function(r){return async.mapLimit(e,10,function(e,n){return r.findOne({gid:e.gid}).exec().then(function(e){return n(null,e)})},function(r,i){if(r)throw r;return n.resolve(_.merge(e,i))})}),n.promise},f={},f.online=function(r){return t.debug("Searching online..."),e.query({action:"search",unit:"aya",traduction:1,query:r,sortedBy:"mushaf",word_info:"False",recitation:0,aya_position_info:"True",aya_sajda_info:"False",fuzzy:"True",script:"standard",vocalized:"True",range:"25",perpage:"25"}).then(function(e){var r;return t.debug("Online search response:",e),r=_(e.data.search.ayas).map(function(e,r){return{gid:e.identifier.gid,index:r}}).toArray().sortBy("index").value()})},f.offline=function(e,r){return(c||u()).then(function(i){var t,a,c,s;return t=o.defer(),r.srtictDiacritics?(s=new RegExp("[](?! "+n.Diacritics.String+")","g"),e=e.replace(s,0/0+n.Diacritics.String+")*"),r.field="standard_full"):e=e.replace(n.Diacritics.RegExp,""),r.ignoreHamzaCase&&(e=e.replace(n.Hamzas.RegExp,n.Hamzas.String)),e=e.replace(/\s{2,}/g," "),e=e.trim(),c=new RegExp(e,"gi"),a={},a[r.field]={$regex:c},i.find(a).sort({gid:1}).exec(function(e,r){if(e)throw e;return t.resolve(r)}),t.promise})},{search:function(e,r){var n;return null==r&&(r={}),r=_.defaults(r,{matches:"autocomplete",srtictDiacritics:!1,ignoreHamzaCase:!0,onlyStartAya:!1,wholeWord:!0,scope:"all",sort:[{sura_id:1},{aya_id:1}],limit:0,skip:0,field:"standard",online:i.search.online.enabled}),e?(n="offline",r.online&&(n="online"),f[n](e,r)["catch"](function(i){if("offline"!==n)return f.offline(e,r);throw i}).then(s).then(function(r){if(r.length)return _.pull(i.search.history,e),i.search.history.unshift(e),i.search.history=i.search.history.slice(0,i.search.max_history),r;throw"NO_RESULTS"})):o.reject("NO_QUERY")}}}]);