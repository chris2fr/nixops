/* -*- Mode: javascript; indent-tabs-mode: nil; c-basic-offset: 2 -*- */

/* -*- Mode: javascript; indent-tabs-mode: nil; c-basic-offset: 2 -*- */

(function() {
  'use strict';

angular.module('SOGo.Common').config(function($mdThemingProvider) {
$mdThemingProvider.definePalette('slateblue', {
  '50': 'edebfc',
  '100': 'd3cef8',
  '200': 'b6aef3',
  '300': '988dee',
  '400': '8274eb',
  '500': '6c5ce7',
  '600': '6454e4',
  '700': '594ae0',
  '800': '4f41dd',
  '900': '3d30d7',
  'A100': 'eeeeee',
  'A200': 'e9e7ff',
  'A400': 'b9b4ff',
  'A700': 'a29bff',
  'contrastDefaultColor': 'light',
  'contrastDarkColors': [
    '50',
    '100',
    '200',
    '300',
    '400',
    'A100',
    'A200',
    'A400',
    'A700'
  ],
  'contrastLightColors': [
    '500',
    '600',
    '700',
    '800',
    '900'
  ]
});
$mdThemingProvider.definePalette('mountainmeadow', {
  '50': 'e0f6f2',
  '100': 'b3eadf',
  '200': '80dcca',
  '300': '4dcdb4',
  '400': '26c3a4',
  '500': '00b894',
  '600': '00b18c',
  '700': '00a881',
  '800': '00a077',
  '900': '009165',
  'A100': 'bdffe7',
  'A200': '8affd5',
  'A400': '57ffc3',
  'A700': '3dffba',
  'contrastDefaultColor': 'light',
  'contrastDarkColors': [
    '50',
    '100',
    '200',
    '300',
    '400',
    'A100',
    'A200',
    'A400',
    'A700'
  ],
  'contrastLightColors': [
    '500',
    '600',
    '700',
    '800',
    '900'
  ]
});
$mdThemingProvider.definePalette('maxyellowred', {
  '50': 'fff9ee',
  '100': 'feefd4',
  '200': 'fee5b7',
  '300': 'fedb9a',
  '400': 'fdd384',
  '500': 'fdcb6e',
  '600': 'fdc666',
  '700': 'fcbe5b',
  '800': 'fcb851',
  '900': 'fcac3f',
  'A100': 'eeeeee',
  'A200': 'eeeeee',
  'A400': 'fff3e4',
  'A700': 'ffe8ca',
  'contrastDefaultColor': 'light',
  'contrastDarkColors': [
    '50',
    '100',
    '200',
    '300',
    '400',
    '500',
    '600',
    '700',
    '800',
    '900',
    'A100',
    'A200',
    'A400',
    'A700'
  ],
  'contrastLightColors': []
});
$mdThemingProvider.definePalette('midnightblue', {
  '50': 'e4e3ec',
  '100': 'bbb9d1',
  '200': '8d8ab2',
  '300': '5f5b93',
  '400': '3d377b',
  '500': '1b1464',
  '600': '18125c',
  '700': '140e52',
  '800': '100b48',
  '900': '080636',
  'A100': '736fff',
  'A200': '413cff',
  'A400': '1009ff',
  'A700': '0700ee',
  'contrastDefaultColor': 'light',
  'contrastDarkColors': [
    '50',
    '100',
    '200',
    'A100'
  ],
  'contrastLightColors': [
    '300',
    '400',
    '500',
    '600',
    '700',
    '800',
    '900',
    'A200',
    'A400',
    'A700'
  ]
});
$mdThemingProvider.definePalette('frenchskyblue', {
  '50': 'eef7ff',
  '100': 'd5eaff',
  '200': 'badcff',
  '300': '9eceff',
  '400': '89c4ff',
  '500': '74b9ff',
  '600': '6cb2ff',
  '700': '61aaff',
  '800': '57a2ff',
  '900': '4493ff',
  'A100': 'eeeeee',
  'A200': 'eeeeee',
  'A400': 'ebf3ff',
  'A700': 'd2e4ff',
  'contrastDefaultColor': 'light',
  'contrastDarkColors': [
    '50',
    '100',
    '200',
    '300',
    '400',
    '500',
    '600',
    '700',
    '800',
    '900',
    'A100',
    'A200',
    'A400',
    'A700'
  ],
  'contrastLightColors': []
});
$mdThemingProvider.definePalette('skobeloff', {
  '50': 'e0eced',
  '100': 'b3d0d1',
  '200': '80b1b3',
  '300': '4d9194',
  '400': '267a7d',
  '500': '006266',
  '600': '005a5e',
  '700': '005053',
  '800': '004649',
  '900': '003438',
  'A100': '6ef4ff',
  'A200': '3bf0ff',
  'A400': '08edff',
  'A700': '00dcee',
  'contrastDefaultColor': 'light',
  'contrastDarkColors': [
    '50',
    '100',
    '200',
    'A100',
    'A200',
    'A400',
    'A700'
  ],
  'contrastLightColors': [
    '300',
    '400',
    '500',
    '600',
    '700',
    '800',
    '900'
  ]
});
    $mdThemingProvider
    .theme('default')
    .primaryPalette('midnightblue')
    .accentPalette('maxyellowred')
    .warnPalette('skobeloff')
    .backgroundPalette('grey');
// });
})();
/*
$mdThemingProvider.theme('gv')
    .primaryPalette('slateblue')
    .accentPalette('mountainmeadow');

*/
/*
angular.module('SOGo.Common').config(function($mdThemingProvider) {
    $mdThemingProvider
    .theme('default')
    .primaryPalette('#6c5ce7')
    .accentPalette('#fdcb6e')
    .warnPalette('#e84393')
    .backgroundPalette('grey');
});
*/
/*
angular.module('SOGo.Common').config(function($mdThemingProvider) {
    $mdThemingProvider
    .theme('default')
    .primaryPalette('blue')
    .accentPalette('teal')
    .warnPalette('red')
    .backgroundPalette('grey');
});
*/
/*
(function() {
  'use strict';

  angular.module('SOGo.Common')
    .config(configure)

  // @ngInject
  configure.$inject = ['$mdThemingProvider'];

  function configure($mdThemingProvider) {
     $mdThemingProvider
      .theme('default')
      .primaryPalette('blue')
      .accentPalette('teal')
      .warnPalette('red')
      .backgroundPalette('grey'); 
});
*/
    /**
     * The SOGo palettes are defined in js/Common/Common.app.js:
     *
     * - sogo-green
     * - sogo-blue
     * - sogo-grey
     *
     * The Material palettes are also available:
     *
     * - red
     * - pink
     * - purple
     * - deep-purple
     * - indigo
     * - blue
     * - light-blue
     * - cyan
     * - teal
     * - green
     * - light-green
     * - lime
     * - yellow
     * - amber
     * - orange
     * - deep-orange
     * - brown
     * - grey
     * - blue-grey
     *
     * See https://material.angularjs.org/latest/Theming/01_introduction
     * and https://material.io/archive/guidelines/style/color.html#color-color-palette
     *
     * You can also define your own palettes. See js/Common/Common.app.js.
     */

    // Create new background palette from grey palette
    /*
    var greyMap = $mdThemingProvider.extendPalette('grey', {
      // background color of sidebar selected item,
      // background color of right panel,
      // background color of menus (autocomplete and contextual menus)
      '200': 'ECEFF4',
      // background color of sidebar
      '300': 'D8DEE9',
       // background color of the busy periods of the attendees editor
      '1000': '4C566A'
    });
    $mdThemingProvider.definePalette('frost-grey', greyMap);

    // Apply new palettes to the default theme, remap some of the hues
    $mdThemingProvider.theme('default')
      .primaryPalette('indigo', {
        'default': '400',  // background color of top toolbars
        'hue-1': '400',
        'hue-2': '600',    // background color of sidebar toolbar
        'hue-3': 'A700'
      })
      .accentPalette('pink', {
        'default': '600',  // background color of fab buttons
        'hue-1': '300',    // background color of center list toolbar
        'hue-2': '300',
        'hue-3': 'A700'
      })
      .backgroundPalette('frost-grey');

    $mdThemingProvider.generateThemesOnDemand(false);
    $mdThemingProvider.theme('blue');
  }
})();
    */

function showLesGV () {
  let linksHome = document.createElement("div");
  let linkGV = document.createElement("a");
  linkGV.innerText="G.V.";
  linkGV.style.color = "var(--lt-color-white)";
  linkGV.style.backgroundColor = "#1b1464";
  linkGV.style.borderRadius = "1rem";
  linkGV.style.paddingRight = "0.5rem"
  linkGV.style.paddingLeft = "0.5rem"
  linkGV.href="https://www.lesgrandsvoisins.com";
  linksHome.appendChild(linkGV);
  let sep = document.createElement("span");
  sep.innerText = " / "
  linksHome.appendChild(sep);
  let linkLesGV = document.createElement("a");
  linkLesGV.innerText="compte";
  linkLesGV.style.color = "var(--lt-color-white)";
  linkLesGV.style.backgroundColor = "#1b1464";
  linkLesGV.style.borderRadius = "1rem";
  linkLesGV.style.paddingRight = "0.5rem"
  linkLesGV.style.paddingLeft = "0.5rem"
  linkLesGV.href="https://www.lesgv.com";
  linksHome.appendChild(linkLesGV);
  document.getElementsByTagName("md-toolbar")[0].appendChild(linksHome);
}
document.onload = (event) => {
  showLesGV();
};
function resolveAfter2Seconds() {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve('resolved');
    }, 8000);
  });
}

async function asyncCall() {
  console.log('calling');
  const result = await resolveAfter2Seconds();
  showLesGV();
  console.log(result);
  // Expected output: "resolved"
}

asyncCall();

