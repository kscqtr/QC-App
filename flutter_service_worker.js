'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "1df5ee28c9955544f2ebe06a6c829b57",
".git/config": "3563a46a4bf4df039744cab47d8f925d",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "71f0895899809c3edbd9374d28fce80a",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "9657c338571eeb0be6d73e61c59a0c26",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b684cfb92ef3597faa020ae14cac8772",
".git/logs/refs/heads/main": "486b25bf9079248d31d2259007120ade",
".git/logs/refs/remotes/origin/HEAD": "3dcca7d4e627cfa34f78d5dab740b63d",
".git/logs/refs/remotes/origin/main": "ca3febb862d6275e09aa8551ca13414f",
".git/objects/00/6664c04af3cc8249b4a4273b1fdda5d02d38c1": "b63a1617b2e1bb7a58b92a745a3bb265",
".git/objects/01/1842b856d2844c35f671e492a3793c1dea487f": "9a7fa59443b8925d7b787ea6939b9d2f",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/04/b5ef9ec1ff8c3c26d5c87503d32977284b99f7": "d06731790dc771d522119db5e600f243",
".git/objects/05/a9c09613574de9b77071261d4429ad6457f4f3": "ac4627b63d6bbc4a63e59c613b45193e",
".git/objects/0f/b75ef4a4b3eb1311c1bbcd6bf0f25653ae112d": "5c97d3c4382450b995fd2bf0b10b6c42",
".git/objects/16/6c6e8efa20b7253b9c7232382d4127451b116c": "d4371110275947a3bd6b9da034e76717",
".git/objects/1e/54a86f80eec9b3da9d72d436cef5639fa8dc66": "3ec681bd76761614c211bd24c8cc4cee",
".git/objects/20/249fa44ace85a54ea046b59c13c1288df86a71": "f171a7351b444187a77bd82f0ee823ab",
".git/objects/27/8d20abbeb5ef718b7e8435bc62aa2249e9ac15": "34c9ddebbc6b03618be2cda6800973c3",
".git/objects/28/6a48c5a453d73fb5ce555f9a0656a923e22e96": "99f80d4c240a77ee916c880b7fc4f03d",
".git/objects/30/6942dc5bda024438722d4da845f397d2b10e14": "682a06660c7a1bece06811374e7444ab",
".git/objects/33/31d9290f04df89cea3fb794306a371fcca1cd9": "e54527b2478950463abbc6b22442144e",
".git/objects/34/21ce9963f3460ae79ae143407035e68a3384e6": "7d817a6c03eb8601cac9e7865aa925c3",
".git/objects/35/96d08a5b8c249a9ff1eb36682aee2a23e61bac": "e931dda039902c600d4ba7d954ff090f",
".git/objects/3a/a1e99fb4300824990d50f046af449ea0541c91": "44fad525b310dc334f511c5dd48f4311",
".git/objects/40/1184f2840fcfb39ffde5f2f82fe5957c37d6fa": "1ea653b99fd29cd15fcc068857a1dbb2",
".git/objects/44/f4d91bc8563f021698373aaa7dc16523264d88": "0cc09c28eaeb1883f893f95d2a592a12",
".git/objects/49/f7d4b3c7f11575c18da76baf6126af5dc50fd4": "b1f4803b23aff24fe4dfc22efcea9738",
".git/objects/4e/0d9f8efb86f69fce020088c7bb426809057e80": "f37c92205b1ebd3f3903b5632beaf235",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/50/4b066754de20e30caf5486964fb6d7c5e15d7b": "adce8043da52181d2ada03dc1a6b2183",
".git/objects/53/e225ee8f69609dab29dc01fdcc9547dc2fa2e4": "27318afb8b3fa87dff16489932ee69a4",
".git/objects/56/b8f8af2fa5c84fa3bddabec426199dfa4ebee8": "7ecacd56b21473739949e9426875dd0c",
".git/objects/57/7946daf6467a3f0a883583abfb8f1e57c86b54": "846aff8094feabe0db132052fd10f62a",
".git/objects/58/79ecfd37180c9360485512cd8ee89eabe8b998": "a2416c59e035fc2e56f1b3ad75719092",
".git/objects/5a/13bd5a18e506d22647433b1980295ce67bcebe": "50b077c2b68b737800ac0d99a322b746",
".git/objects/5e/8448cfdd8ff56e1090bdec7886e124dc40e632": "bb77138b3a7314f7a73f388f2a84d9ad",
".git/objects/5f/bf1f5ee49ba64ffa8e24e19c0231e22add1631": "f19d414bb2afb15ab9eb762fd11311d6",
".git/objects/5f/d6421afa77adace0bf4e12f0e03d8c6ced0037": "317aab5e0f8b1b0bb90c72c64499277f",
".git/objects/64/5116c20530a7bd227658a3c51e004a3f0aefab": "f10b5403684ce7848d8165b3d1d5bbbe",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6d/f2b253603094de7f39886aae03181c686e375b": "4e432986780adf1da707b08f0bc71809",
".git/objects/6e/8d415ecb670d8417c29388b6f4d259b0bbdaf3": "a2e450c2deb268a36663fe3edd0cd5d9",
".git/objects/73/5fe05d2d9072b1c725a7c5304bd56445371b1e": "60897b768b1848dede52743f3835bccd",
".git/objects/74/c41c37cf040459b20f6f6577535c8542b1c589": "e866f58333297de664d76536fe3631c2",
".git/objects/75/26189e800a69d72c88ff3892fc23d8a5b25ae6": "efa97f6c6850d61a5ba2e8bdf196f99a",
".git/objects/79/dd092fbb3498b0467d7e1ee29ec400b938e449": "b42cdcb853db32bda77db0e2cf7d40d4",
".git/objects/82/07be371cf72d656e789bb04e32087523bff719": "77a4137636896312981604300821fcd7",
".git/objects/85/275944e8b29915196f859a7bd17f2a7c2d66d3": "bb34f0d99c39f786ed26f5ca2fda7fa1",
".git/objects/86/34a97c911ebed728ca5d3ca1ecbd526e7e6533": "a19c71a985a50a082c95d30c9c7ade17",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/89/50eb459076dc3f698a2b1d222f1d2e4945bca5": "397fba82713ffae2ac5e15c92e0ac34e",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/90/5db008c0ff5e2d36a398ee6a54b86eaed0a637": "53609a9d8243a0f81b7f78ce769e65c4",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/93/329db5a15bfe61e3d328446b2c3b538443e4b0": "3852a95eb13871431c201971cad2a3af",
".git/objects/93/67abd01959cfb656383100ba0ed16dd827afd0": "fa65055f30d1a97a48d631609275bd82",
".git/objects/97/c15d3782088937b810a4df7dc5bd7adfe998b0": "4db16c2ae04bb1fa89684b43bef7f499",
".git/objects/98/433bcc80f92f4b08d171b49ffe914312ce2987": "d1f1a71a2bd956db660670889a59d148",
".git/objects/98/47137d40eb9b1089a795a6ec597a1c901c5123": "f700bb886e485defcabf63a9d5162549",
".git/objects/9d/1ceb25ec73acabd1875ad4a2cad965e9a6d136": "14df1a8058b62a11a10eda82463f690a",
".git/objects/9f/7512e7693ea1f2dc1bc50e697de79dbee544d2": "9a6e24ff7e62698ee9c85958024af45d",
".git/objects/9f/d32e71d158ab406510e447253252dcd6fc6d02": "e94689cfa16e8c4163ca0a7220b29d48",
".git/objects/a0/899fff514fbe27c26e3c2f51377d4fa1c8af54": "bff628c9c9ec0c869a16f2f94a3aeb76",
".git/objects/a5/6b931f64b23fba5cd6c465a016f476ae567991": "d5f49a3114351964f91d119f0b5f5323",
".git/objects/a5/d65b43d0f7cafd1b0a928da519e5a77698c2bf": "7ed03f23165cb16d740428d3b951b120",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/ab/56137ccafd8bc6ebad063a37036cb22e3c1bf2": "0b63d336a67206b0a2b9f6577a7e5ee3",
".git/objects/b5/2dc4437ae5cbdbb294f3d4a561b54ae555c03e": "ed64af5c7c42b3827fa9420ee9212d2a",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/be/2b34d4144010d9b55abeea026b9effd12376fb": "7a401b63e336906f4e11006233a5d7b9",
".git/objects/be/fce6af890a4edf6d3c858878b30c1c2e2cd803": "a6c70daafc28408c562234b3d09e0578",
".git/objects/c0/2cb0f99b75259e081c665c391683b89f58c3f1": "3cfb4d84b8a16eda7cf8da2ebad18412",
".git/objects/c7/88160ed3acb1742a90cfa5db0c5dff6e634116": "456f103703f1c6ed949d7808c38450b1",
".git/objects/cd/60117bea6742feb17a28a8c856d77373d8da35": "603de4903250a22168b0a806d57317c6",
".git/objects/d1/d7e7d30615fe6ec88bb41d6dd5cdd587938a35": "1a0211c86099ca4ff9ddd9b37359ce49",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/dd/28d7286c4e336dd4c0e630f40756969e827841": "25cb7e2cee376c2616ed2ee305459919",
".git/objects/e4/05f74cba92dc161b01cb832ab58d55498c8b72": "83b39911492b881969f12caefaa48054",
".git/objects/e6/2450a1f2c465ee824ddda3c2c92188128c9cce": "7c11de59fc6b99c62b1c1af596fff0ee",
".git/objects/e6/eea3e99725dca638e176b81bc66b1149b96862": "a535d24f52903a01f0794e707a199ba6",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/83a0c8186974ffea68a40a476871556774e27d": "d0fb321e512de9cc0480f5d69474de8b",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/c9ebab0d53e1f95e6b4943880321d0dc187ade": "88908e835f3a41103cb8bf0c6848b093",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/fa/bce47527db78e2afc91755c8cceb3ab3336eb9": "817178a66e1b539bbafe7e5f66ca1bc2",
".git/objects/fa/cad0cf50bf4fb46d0817a528998898f95b8e33": "6d9f22f73e2309bb2f910ad50e22e6ee",
".git/objects/fb/f9ec0d0795a2fd09e7f81898156e74cbfe5e44": "b0293345319151e993ceeb949629e11a",
".git/objects/fe/ef09b635e13007ef4f68f76f8608bcea16c859": "262aa35037792cc3bec7860142f1acf1",
".git/refs/heads/main": "2f9c6a78b1df536d5f40987c43879bad",
".git/refs/remotes/origin/HEAD": "98b16e0b650190870f1b40bc8f4aec4e",
".git/refs/remotes/origin/main": "2f9c6a78b1df536d5f40987c43879bad",
"assets/AssetManifest.bin": "13572ec97491a830fd4f653c91ee3e18",
"assets/AssetManifest.bin.json": "3b9775f591fce2e6b8dd21693146c4f4",
"assets/AssetManifest.json": "d5f8df1d7f30887858a236f0db7b168d",
"assets/FontManifest.json": "866b9b20ab0e8c30ffe220d2a2d66abe",
"assets/fonts/MaterialIcons-Regular.otf": "7d8501debd4b71a45b4955d13e6f031d",
"assets/images/conductor_resistance.png": "5a9c358d84294ae14c7a7d114da6301a",
"assets/images/dumbbell_calculation.png": "cb193f5f156ceda225bdeb4b0f5d445d",
"assets/images/dumbbell_conversion.png": "469b32878a1a78db0ac51d0060a98f71",
"assets/images/dumbbell_weight.png": "d17b65f0e66b6a26bf3751629aabb46a",
"assets/images/hot_set.png": "cb193f5f156ceda225bdeb4b0f5d445d",
"assets/images/hot_set_dumbbell.jpg": "7bd1df6848d7337baac2ea3e4659d662",
"assets/images/hot_set_tubular.jpg": "70d6f4c5a024404ea659d8d732a902da",
"assets/images/insulation_resistance.png": "812cdd2cc3823a67e403c95aa40eead8",
"assets/images/keystone.png": "cd9afe15ae2e4561eb4bfb4720269d2e",
"assets/images/pdfs/conductor_resistance.pdf": "64650c4fc04aaad0d2cc138994a344b5",
"assets/images/pdfs/hot_set_dumbbell.pdf": "11fef90c7e2d7ea8178e3bff609bbef9",
"assets/images/pdfs/hot_set_tubular.pdf": "11fef90c7e2d7ea8178e3bff609bbef9",
"assets/images/pdfs/insulation_resistance.pdf": "edf47c5256b26ad464a8ee4feb02b99d",
"assets/images/pdfs/shrinkage.pdf": "ba4490b522661605df8fad0f4866b975",
"assets/images/shrinkage.png": "d9d4e06c500fb4ae3759d416d7e182cd",
"assets/NOTICES": "0cba387a6943f8f139fadea45a264488",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/syncfusion_flutter_pdfviewer/assets/fonts/RobotoMono-Regular.ttf": "5b04fdfec4c8c36e8ca574e40b7148bb",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/highlight.png": "2aecc31aaa39ad43c978f209962a985c",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/squiggly.png": "68960bf4e16479abb83841e54e1ae6f4",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/strikethrough.png": "72e2d23b4cdd8a9e5e9cadadf0f05a3f",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/underline.png": "59886133294dd6587b0beeac054b2ca3",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/highlight.png": "2fbda47037f7c99871891ca5e57e030b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/squiggly.png": "9894ce549037670d25d2c786036b810b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/strikethrough.png": "26f6729eee851adb4b598e3470e73983",
"assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/underline.png": "a98ff6a28215341f764f96d627a5d0f5",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "d0b7d812876bde0898104716feac6647",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "2323a41418af787c179b2930e9bc3c62",
"/": "2323a41418af787c179b2930e9bc3c62",
"main.dart.js": "b98e596779895190c5a355caa303d645",
"manifest.json": "5723b42f17425fb1cdda6278e703e85a",
"README.md": "c69c1cb4d7dcf7216d99dfd5095080f6",
"version.json": "ed710bad5af15d9e8c7353d874be9183"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
