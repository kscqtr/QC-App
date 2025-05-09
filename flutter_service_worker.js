'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/AUTO_MERGE": "4abeb73e205b02cf7d06153417801690",
".git/COMMIT_EDITMSG": "24d81427319b488f951c1073124caa5c",
".git/config": "3563a46a4bf4df039744cab47d8f925d",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/FETCH_HEAD": "83725d702351ec97f4dbe52a3b9018c0",
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
".git/index": "88b512f0bd55aa5fbbd751ef02ad428d",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "b8aada35811a15f065d6429ac6cef71b",
".git/logs/refs/heads/main": "afc4305eb36fe6810f06f632a86e29f5",
".git/logs/refs/remotes/origin/HEAD": "3dcca7d4e627cfa34f78d5dab740b63d",
".git/logs/refs/remotes/origin/main": "cb5172fad55f561cdc38803968643a93",
".git/MERGE_HEAD": "2293b20aa6b837110c751f3653e66913",
".git/MERGE_MODE": "d41d8cd98f00b204e9800998ecf8427e",
".git/MERGE_MSG": "7eeb8b234d98a20c211adc92e2fcef9b",
".git/objects/00/6664c04af3cc8249b4a4273b1fdda5d02d38c1": "b63a1617b2e1bb7a58b92a745a3bb265",
".git/objects/01/1842b856d2844c35f671e492a3793c1dea487f": "9a7fa59443b8925d7b787ea6939b9d2f",
".git/objects/03/2fe904174b32b7135766696dd37e9a95c1b4fd": "80ba3eb567ab1b2327a13096a62dd17e",
".git/objects/04/b5ef9ec1ff8c3c26d5c87503d32977284b99f7": "d06731790dc771d522119db5e600f243",
".git/objects/05/2d6a448fbd701c58bd726c70929a98031f6223": "2a7f9cbe2df6034fb119de3c40c997a8",
".git/objects/05/a9c09613574de9b77071261d4429ad6457f4f3": "ac4627b63d6bbc4a63e59c613b45193e",
".git/objects/0d/9ecafff55e1e7bb3088248bb67ebbea9375ff2": "1b507990e6685c09b7dab45038e72ea6",
".git/objects/0f/b75ef4a4b3eb1311c1bbcd6bf0f25653ae112d": "5c97d3c4382450b995fd2bf0b10b6c42",
".git/objects/16/6c6e8efa20b7253b9c7232382d4127451b116c": "d4371110275947a3bd6b9da034e76717",
".git/objects/1a/dc2cce5d90823f8b544f3b36a8cb64cb555425": "b9c5bc33c6881c02e40ac87de2caad80",
".git/objects/1e/088786d7a4883172679aa3a2e49d8a8d8e0b3f": "664fabd662d6df63b88172dbbc16b277",
".git/objects/1e/54a86f80eec9b3da9d72d436cef5639fa8dc66": "3ec681bd76761614c211bd24c8cc4cee",
".git/objects/1f/b672ea1395fd793cb986c5fea7329f8f8e8c25": "abbf948f0841864a46d0e0f2d1c12479",
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
".git/objects/49/6e6eb3843becdbda1a0e455781cd7518e74f3c": "1e64e6f9e33c5e8ddb8327ca4ec342e5",
".git/objects/49/f7d4b3c7f11575c18da76baf6126af5dc50fd4": "b1f4803b23aff24fe4dfc22efcea9738",
".git/objects/4e/0d9f8efb86f69fce020088c7bb426809057e80": "f37c92205b1ebd3f3903b5632beaf235",
".git/objects/4f/02e9875cb698379e68a23ba5d25625e0e2e4bc": "254bc336602c9480c293f5f1c64bb4c7",
".git/objects/50/4b066754de20e30caf5486964fb6d7c5e15d7b": "adce8043da52181d2ada03dc1a6b2183",
".git/objects/50/7c592a90c3dc01cdb2f60d364a63dc0e761934": "6ca29a2d76eb01fa5ea3d5e75e6d7502",
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
".git/objects/89/c46c592699549421167c5722eedae3b668d1b2": "9f080bee76590bbfc3987eb7c2f4cb9d",
".git/objects/8a/51a9b155d31c44b148d7e287fc2872e0cafd42": "9f785032380d7569e69b3d17172f64e8",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/90/5db008c0ff5e2d36a398ee6a54b86eaed0a637": "53609a9d8243a0f81b7f78ce769e65c4",
".git/objects/91/4a40ccb508c126fa995820d01ea15c69bb95f7": "8963a99a625c47f6cd41ba314ebd2488",
".git/objects/93/329db5a15bfe61e3d328446b2c3b538443e4b0": "3852a95eb13871431c201971cad2a3af",
".git/objects/93/67abd01959cfb656383100ba0ed16dd827afd0": "fa65055f30d1a97a48d631609275bd82",
".git/objects/97/c15d3782088937b810a4df7dc5bd7adfe998b0": "4db16c2ae04bb1fa89684b43bef7f499",
".git/objects/98/433bcc80f92f4b08d171b49ffe914312ce2987": "d1f1a71a2bd956db660670889a59d148",
".git/objects/98/47137d40eb9b1089a795a6ec597a1c901c5123": "f700bb886e485defcabf63a9d5162549",
".git/objects/9a/22d1ca5f501df3f3c6e81620fe220db56835d0": "e10d0fc33d9c16318fff7ea40539bbfd",
".git/objects/9d/1ceb25ec73acabd1875ad4a2cad965e9a6d136": "14df1a8058b62a11a10eda82463f690a",
".git/objects/9f/7512e7693ea1f2dc1bc50e697de79dbee544d2": "9a6e24ff7e62698ee9c85958024af45d",
".git/objects/9f/d32e71d158ab406510e447253252dcd6fc6d02": "e94689cfa16e8c4163ca0a7220b29d48",
".git/objects/a0/899fff514fbe27c26e3c2f51377d4fa1c8af54": "bff628c9c9ec0c869a16f2f94a3aeb76",
".git/objects/a5/6b931f64b23fba5cd6c465a016f476ae567991": "d5f49a3114351964f91d119f0b5f5323",
".git/objects/a5/d65b43d0f7cafd1b0a928da519e5a77698c2bf": "7ed03f23165cb16d740428d3b951b120",
".git/objects/a5/de584f4d25ef8aace1c5a0c190c3b31639895b": "9fbbb0db1824af504c56e5d959e1cdff",
".git/objects/a8/8c9340e408fca6e68e2d6cd8363dccc2bd8642": "11e9d76ebfeb0c92c8dff256819c0796",
".git/objects/ab/56137ccafd8bc6ebad063a37036cb22e3c1bf2": "0b63d336a67206b0a2b9f6577a7e5ee3",
".git/objects/ac/d47b7671d53b7a9b573cee69429c49798fa51e": "1f7f66084ed662332fbb9cb3d3e80675",
".git/objects/b4/63081592d647be266949679e52824aef8fd729": "b38fcbbfd23af8cd65f9b999256b9027",
".git/objects/b5/2dc4437ae5cbdbb294f3d4a561b54ae555c03e": "ed64af5c7c42b3827fa9420ee9212d2a",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/b9/c229fdb9daab07864a71589e481d098eea2f1b": "fc8ec96e9590d5f04bc52915f9e7dc01",
".git/objects/be/2b34d4144010d9b55abeea026b9effd12376fb": "7a401b63e336906f4e11006233a5d7b9",
".git/objects/be/fce6af890a4edf6d3c858878b30c1c2e2cd803": "a6c70daafc28408c562234b3d09e0578",
".git/objects/c0/2cb0f99b75259e081c665c391683b89f58c3f1": "3cfb4d84b8a16eda7cf8da2ebad18412",
".git/objects/c7/88160ed3acb1742a90cfa5db0c5dff6e634116": "456f103703f1c6ed949d7808c38450b1",
".git/objects/cd/60117bea6742feb17a28a8c856d77373d8da35": "603de4903250a22168b0a806d57317c6",
".git/objects/d1/d7e7d30615fe6ec88bb41d6dd5cdd587938a35": "1a0211c86099ca4ff9ddd9b37359ce49",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/94f7d500c975e8de31df182433415a64998ae1": "ddad4efb40040a1cac12293712f4af67",
".git/objects/d6/2b7521a6c69bc400597308f9fe2dadf971d873": "41a3496383c43350d2630b8b2f39dd18",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/d9/3952e90f26e65356f31c60fc394efb26313167": "1401847c6f090e48e83740a00be1c303",
".git/objects/d9/95d95c0d4b639b3b3dc47e23ad2e3893bb9673": "ad6d50cc8abf4416f3b4b8d22618a237",
".git/objects/dd/28d7286c4e336dd4c0e630f40756969e827841": "25cb7e2cee376c2616ed2ee305459919",
".git/objects/e4/05f74cba92dc161b01cb832ab58d55498c8b72": "83b39911492b881969f12caefaa48054",
".git/objects/e6/2450a1f2c465ee824ddda3c2c92188128c9cce": "7c11de59fc6b99c62b1c1af596fff0ee",
".git/objects/e6/eea3e99725dca638e176b81bc66b1149b96862": "a535d24f52903a01f0794e707a199ba6",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ec/83a0c8186974ffea68a40a476871556774e27d": "d0fb321e512de9cc0480f5d69474de8b",
".git/objects/ef/b875788e4094f6091d9caa43e35c77640aaf21": "27e32738aea45acd66b98d36fc9fc9e0",
".git/objects/ef/f1d4541bbf329f441cd3ce3c94e8291825b7ea": "ed207a9755bddf2246a5c03fa7133709",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f2/c9ebab0d53e1f95e6b4943880321d0dc187ade": "88908e835f3a41103cb8bf0c6848b093",
".git/objects/f3/709a83aedf1f03d6e04459831b12355a9b9ef1": "538d2edfa707ca92ed0b867d6c3903d1",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/fa/bce47527db78e2afc91755c8cceb3ab3336eb9": "817178a66e1b539bbafe7e5f66ca1bc2",
".git/objects/fa/cad0cf50bf4fb46d0817a528998898f95b8e33": "6d9f22f73e2309bb2f910ad50e22e6ee",
".git/objects/fb/f9ec0d0795a2fd09e7f81898156e74cbfe5e44": "b0293345319151e993ceeb949629e11a",
".git/objects/fe/ef09b635e13007ef4f68f76f8608bcea16c859": "262aa35037792cc3bec7860142f1acf1",
".git/objects/pack/pack-abb5496aa9e0e8f86147e0528d082dcc6075c0b3.idx": "12658fef14847cc42cb0fcd250f29f47",
".git/objects/pack/pack-abb5496aa9e0e8f86147e0528d082dcc6075c0b3.pack": "99cdbdfd6602bd455465ad21449d4301",
".git/objects/pack/pack-abb5496aa9e0e8f86147e0528d082dcc6075c0b3.rev": "53c55067a5e6f549eb335f3ea7cc9c99",
".git/ORIG_HEAD": "9f8c1f4188007d697b7cc5bdb4e52447",
".git/refs/heads/main": "9f8c1f4188007d697b7cc5bdb4e52447",
".git/refs/remotes/origin/HEAD": "98b16e0b650190870f1b40bc8f4aec4e",
".git/refs/remotes/origin/main": "2293b20aa6b837110c751f3653e66913",
"analysis_options.yaml": "9e65f4b9beebb674c0dc252f70a5c177",
"android/app/build.gradle.kts": "e13a6e6be54391548bd4c4e851df6ecd",
"android/app/src/debug/AndroidManifest.xml": "820c45a25b424dd5b7388330f7548d1f",
"android/app/src/main/AndroidManifest.xml": "0b8b13a50510e6507a26592c7e8785ec",
"android/app/src/main/kotlin/com/example/calculator/MainActivity.kt": "64150e12d4ab19497fc15292a9e44622",
"android/app/src/main/res/drawable/launch_background.xml": "12c379b886cbd7e72cfee6060a0947d4",
"android/app/src/main/res/drawable-v21/launch_background.xml": "bff4b9cd8e98754261159601bd94abd3",
"android/app/src/main/res/mipmap-hdpi/ic_launcher.png": "13e9c72ec37fac220397aa819fa1ef2d",
"android/app/src/main/res/mipmap-mdpi/ic_launcher.png": "6270344430679711b81476e29878caa7",
"android/app/src/main/res/mipmap-xhdpi/ic_launcher.png": "a0a8db5985280b3679d99a820ae2db79",
"android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png": "afe1b655b9f32da22f9a4301bb8e6ba8",
"android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png": "57838d52c318faff743130c3fcfae0c6",
"android/app/src/main/res/values/styles.xml": "f8b8cfbf977690d117f4dade5d27a789",
"android/app/src/main/res/values-night/styles.xml": "c22fb29c307f2a6ae4317b3a5e577688",
"android/app/src/profile/AndroidManifest.xml": "820c45a25b424dd5b7388330f7548d1f",
"android/build.gradle.kts": "0be80ea97a9d674e007d056c9b84ed4c",
"android/gradle/wrapper/gradle-wrapper.properties": "d234953991000ffcae6bde4f826801f6",
"android/gradle.properties": "177a9eb502bc9c110a72ff0fdfd0c845",
"android/settings.gradle.kts": "956d4473f20d5d82ed78be4ced888df2",
"assets/AssetManifest.bin": "4a096275187ef810be9d13da0221a0c8",
"assets/AssetManifest.bin.json": "a2a6437d5b8a8ed7fd98b9bc7b343603",
"assets/AssetManifest.json": "3d0a5739d670babb3705cedb0b9153ed",
"assets/FontManifest.json": "866b9b20ab0e8c30ffe220d2a2d66abe",
"assets/fonts/MaterialIcons-Regular.otf": "7d8501debd4b71a45b4955d13e6f031d",
"assets/images/ageing.png": "6a8ee93825d5456f8335f4b7ff55877e",
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
"flutter_bootstrap.js": "b8c0df25311158711e185bd8781ac8dd",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"images/ageing.png": "6a8ee93825d5456f8335f4b7ff55877e",
"images/conductor_resistance.png": "5a9c358d84294ae14c7a7d114da6301a",
"images/dumbbell_calculation.png": "cb193f5f156ceda225bdeb4b0f5d445d",
"images/dumbbell_conversion.png": "469b32878a1a78db0ac51d0060a98f71",
"images/dumbbell_weight.png": "d17b65f0e66b6a26bf3751629aabb46a",
"images/hot_set.png": "cb193f5f156ceda225bdeb4b0f5d445d",
"images/hot_set_dumbbell.jpg": "7bd1df6848d7337baac2ea3e4659d662",
"images/hot_set_tubular.jpg": "70d6f4c5a024404ea659d8d732a902da",
"images/insulation_resistance.png": "812cdd2cc3823a67e403c95aa40eead8",
"images/Keystone.png": "cd9afe15ae2e4561eb4bfb4720269d2e",
"images/Old%20pictures/dumbbell_calculation%20(old).png": "4d79ce16e187e04680990a0dfd1ac20a",
"images/Old%20pictures/dumbbell_weight%20(old).png": "ab327aa31a591a7798d914665b5f494e",
"images/Old%20pictures/hot_set_dumbbell%20(old).png": "4148db61d3a7118ab3186d051a3d3f35",
"images/Old%20pictures/hot_set_tubular%20(old).png": "6ee8cff867a39741b9a6a7a765798f2d",
"images/pdfs/conductor_resistance.pdf": "64650c4fc04aaad0d2cc138994a344b5",
"images/pdfs/hot_set_dumbbell.pdf": "11fef90c7e2d7ea8178e3bff609bbef9",
"images/pdfs/hot_set_tubular.pdf": "11fef90c7e2d7ea8178e3bff609bbef9",
"images/pdfs/insulation_resistance.pdf": "edf47c5256b26ad464a8ee4feb02b99d",
"images/pdfs/shrinkage.pdf": "ba4490b522661605df8fad0f4866b975",
"images/shrinkage.png": "d9d4e06c500fb4ae3759d416d7e182cd",
"images/Sustainability.png": "37212152588a949a4e0338e4e58a8ba4",
"index.html": "2323a41418af787c179b2930e9bc3c62",
"/": "2323a41418af787c179b2930e9bc3c62",
"ios/Flutter/AppFrameworkInfo.plist": "09ece6f06f706864eb9c343ad93b57c8",
"ios/Flutter/Debug.xcconfig": "e2f44c1946b223a1ce15cefc6ba9ad67",
"ios/Flutter/Release.xcconfig": "e2f44c1946b223a1ce15cefc6ba9ad67",
"ios/Runner/AppDelegate.swift": "e277c49e98c9f80e9e71c0524a5cb60f",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json": "31a08e429403e265cabfb31b3d65f049",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png": "c785f8932297af4acd5f5ccb7630f01c",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png": "a2f8558fb1d42514111fbbb19fb67314",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png": "2247a840b6ee72b8a069208af170e5b1",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png": "1b3b1538136316263c7092951e923e9d",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png": "be8887071dd7ec39cb754d236aa9584f",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png": "043119ef4faa026ff82bd03f241e5338",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png": "2b1452c4c1bda6177b4fbbb832df217f",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png": "2247a840b6ee72b8a069208af170e5b1",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png": "8245359312aea1b0d2412f79a07b0ca5",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png": "5b3c0902200ce596e9848f22e1f0fe0e",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png": "5b3c0902200ce596e9848f22e1f0fe0e",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png": "e419d22a37bc40ba185aca1acb6d4ac6",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png": "36c0d7a7132bdde18898ffdfcfcdc4d2",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png": "643842917530acf4c5159ae851b0baf2",
"ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png": "665cb5e3c5729da6d639d26eff47a503",
"ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json": "b9e927ac17345f2d5f052fe68a3487f9",
"ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png": "978c1bee49d7ad5fc1a4d81099b13e18",
"ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png": "978c1bee49d7ad5fc1a4d81099b13e18",
"ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png": "978c1bee49d7ad5fc1a4d81099b13e18",
"ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md": "f7ee1b402881509d197f34963e569927",
"ios/Runner/Base.lproj/LaunchScreen.storyboard": "b428258a72232cdd2cc04136ec23e656",
"ios/Runner/Base.lproj/Main.storyboard": "2b4e6b099f6729340a5ecc272c06cff7",
"ios/Runner/Info.plist": "6436e981768876e16508f881dc5ea758",
"ios/Runner/Runner-Bridging-Header.h": "7ad7b5cea096132de13ba526b2b9efbe",
"ios/Runner.xcodeproj/project.pbxproj": "8dbc20ea9176f735c3424a0d2c060be7",
"ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata": "77d69f353bbf342ad71a24f69ec331ff",
"ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist": "7e8ed88ea03cf8357fe1c73ae979f345",
"ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings": "ecb41062214c654f65e47faa71e6b52e",
"ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme": "d2a77de70d304fc1a7f8dd7a94a83aa3",
"ios/Runner.xcworkspace/contents.xcworkspacedata": "ac9a90958f80f9cc1d0d5301144fb629",
"ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist": "7e8ed88ea03cf8357fe1c73ae979f345",
"ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings": "ecb41062214c654f65e47faa71e6b52e",
"ios/RunnerTests/RunnerTests.swift": "24e5d095048eb86c30423f4e04b6e57b",
"lib/main.dart": "8c3b4c0ef6a42b1ee58b15e18014635e",
"lib/pages/ageing_page.dart": "3e622274c80833709c1471b03f75189e",
"lib/pages/ambient_temperature_page.dart": "42a25b588e6ea2485631e4b100896c93",
"lib/pages/calculator_page.dart": "43b4abfabd69fa5561354a338b56d9c9",
"lib/pages/capacitance_unbalance_page.dart": "c6db893525f5e6b55241bdc1c705f28d",
"lib/pages/conductor_resistance_page.dart": "1b06efe1caea2594f2f5e212bb23a991",
"lib/pages/constant_ki_page.dart": "71ef28dbe7d1e41d9fd385bda44bb51f",
"lib/pages/dumbbell_calculation2_page.dart": "6482dd0ae0598a5cd6e6faea2730d3ed",
"lib/pages/dumbbell_calculation_page.dart": "cefb8a9576cb248460965738a6d637c9",
"lib/pages/dumbbell_weight_page.dart": "630a4516538548427c3381fa8286d05c",
"lib/pages/hot_set_page.dart": "60882c0e5d13150af6b188414270d818",
"lib/pages/hot_set_weight_selection_page.dart": "d4af4a6cb92a06f51fb49514d0d045f3",
"lib/pages/insulation_resistance_page.dart": "046cbbb277f2b51ab6549b0044082718",
"lib/pages/mutual_capacitance_page.dart": "9d3933884e6fbc3e12a3f8817a8a6785",
"lib/pages/pdf_viewer_page.dart": "d5a11e4b9a59e54506e5cb1ae8773f48",
"lib/pages/selection_page.dart": "3005a29be1e6802491527bde7443a044",
"lib/pages/shrinkage_page.dart": "884b41724191686623db2ce5a9b22e82",
"lib/pages/test_page.dart": "13711b595c0a732ce6d97fe368643b25",
"lib/pages/tubular_weight_page.dart": "dd69de6a85d77ce65075b95f1157bf14",
"linux/CMakeLists.txt": "3748605904252c4899f059c3a3802db8",
"linux/flutter/CMakeLists.txt": "2195470ce31675d31db5a37590d011f6",
"linux/flutter/generated_plugins.cmake": "33d9640f2839ba193a4c2bb512c034ae",
"linux/flutter/generated_plugin_registrant.cc": "d4615e983185e91a48de32da2c94740c",
"linux/flutter/generated_plugin_registrant.h": "0208db974972d7b29a0ac368be83644b",
"linux/runner/CMakeLists.txt": "30cc1614b16214b66c014af09ba699eb",
"linux/runner/main.cc": "539395bcd63dba20afed0838d136189f",
"linux/runner/my_application.cc": "015e02f505ff6d793967d060f5f42324",
"linux/runner/my_application.h": "f6b37d58752c8671078b6f660e33e8c1",
"macos/Flutter/Flutter-Debug.xcconfig": "f6991d7432e1664af118cc9531127016",
"macos/Flutter/Flutter-Release.xcconfig": "f6991d7432e1664af118cc9531127016",
"macos/Flutter/GeneratedPluginRegistrant.swift": "0d67caf3365c4b9c7342c940b6fe843c",
"macos/Runner/AppDelegate.swift": "4b52e0b89ebfef9baf45b04548c463d6",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png": "c9becc9105f8cabce934d20c7bfb6aac",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png": "3ded30823804caaa5ccc944067c54a36",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png": "8bf511604bc6ed0a6aeb380c5113fdcf",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png": "dfe2c93d1536ae02f085cc63faa3430e",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png": "8e0ae58e362a6636bdfccbc04da2c58c",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png": "0ad44039155424738917502c69667699",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png": "04e7b6ef05346c70b663ca1d97de3ad5",
"macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json": "1d48e925145d4b573a3b5d7960a1c585",
"macos/Runner/Base.lproj/MainMenu.xib": "85bdf02ea39336686f2e0ff5f52137cc",
"macos/Runner/Configs/AppInfo.xcconfig": "199c37f7aa2ec827a14b0a0841b805b4",
"macos/Runner/Configs/Debug.xcconfig": "783e2b0e2aa72d8bc215462bb8d1569d",
"macos/Runner/Configs/Release.xcconfig": "709485d8ea7b78479bf23eb64281287d",
"macos/Runner/Configs/Warnings.xcconfig": "bbde97fb62099b5b9879fb2ffeb1a0a0",
"macos/Runner/DebugProfile.entitlements": "4ad77e84621dc5735c16180a0934fcde",
"macos/Runner/Info.plist": "9ffcbec0a18fdad9d3d606656fd46f9a",
"macos/Runner/MainFlutterWindow.swift": "93c22dae2d93f3dc1402e121901f582b",
"macos/Runner/Release.entitlements": "fc4ad575c1efec3d097fb9d40a0f702f",
"macos/Runner.xcodeproj/project.pbxproj": "09c2ea59d9e0d3f920affc57e7241bd6",
"macos/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist": "7e8ed88ea03cf8357fe1c73ae979f345",
"macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme": "5818d44ebb9945bae49de04cf862c0b7",
"macos/Runner.xcworkspace/contents.xcworkspacedata": "ac9a90958f80f9cc1d0d5301144fb629",
"macos/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist": "7e8ed88ea03cf8357fe1c73ae979f345",
"macos/RunnerTests/RunnerTests.swift": "8059f5d27a19c556eeafb49b3f9b7bdd",
"main.dart.js": "8ba2c94fbe951ae51f91e021ad6f196d",
"manifest.json": "5723b42f17425fb1cdda6278e703e85a",
"pubspec.lock": "b68cc56f1a3823f9fac27dd0886b4b47",
"pubspec.yaml": "ae67b374b9b067b1303e3a0025f6bec1",
"README.md": "e1cab199382a26df09ecc0e26239215c",
"test/widget_test.dart": "3984673ab82e86b4f39d57ebc91173c2",
"version.json": "ed710bad5af15d9e8c7353d874be9183",
"web/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"web/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"web/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"web/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"web/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"web/index.html": "8585831b28a897fcb6e8fb8adf469d44",
"web/manifest.json": "5723b42f17425fb1cdda6278e703e85a",
"windows/CMakeLists.txt": "c9675b10d44edf0cd84a16aba50039c1",
"windows/flutter/CMakeLists.txt": "bbf66fed5180bd9ae8198b8d7c4a0001",
"windows/flutter/generated_plugins.cmake": "4d4d13947934f3f586981c4bc04bc722",
"windows/flutter/generated_plugin_registrant.cc": "51387ab5cfd0fd21754374bc1075448c",
"windows/flutter/generated_plugin_registrant.h": "0c3df6700414e7f332dfa2582a1ae29e",
"windows/runner/CMakeLists.txt": "028602ab9754bffe716659ada7590d29",
"windows/runner/flutter_window.cpp": "2f463f9b7da67a2d692a012f9ea85e0c",
"windows/runner/flutter_window.h": "7defcc89d4a26d56e801241d624d48fb",
"windows/runner/main.cpp": "91f1d8609c9f6e90e4df4f580349cc05",
"windows/runner/resource.h": "1ade5dd15e613479a15e8832ed276f2b",
"windows/runner/resources/app_icon.ico": "6ea04d80ca2a3fa92c7717c3c44ccc19",
"windows/runner/runner.exe.manifest": "298a0260a755c3959d2c3c8904298803",
"windows/runner/Runner.rc": "058c1a2bb1a28e91acb6d84df9dc1a1a",
"windows/runner/utils.cpp": "432461b09d862a2f8dadf380ff0e34e5",
"windows/runner/utils.h": "fd81e143f5614eb6fd75efe539002853",
"windows/runner/win32_window.cpp": "571eb8234dbc2661be03aa5f2a4d2fca",
"windows/runner/win32_window.h": "7569387d58711ab975940f4df3b4bcda"};
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
