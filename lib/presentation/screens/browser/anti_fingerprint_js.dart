import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AntiFingerprintJS {
  AntiFingerprintJS._();

  /// Generates comprehensive anti-fingerprinting JavaScript injection
  static String buildScript({
    bool blockCanvas = true,
    bool blockAudio = true,
    bool blockWebGL = true,
    bool blockWebRtc = true,
    bool spoofTimezone = true,
    bool blockNavigatorProps = true,
  }) {
    final parts = <String>[];

    if (blockCanvas) parts.add(_canvasBlock);
    if (blockAudio) parts.add(_audioContextBlock);
    if (blockWebGL) parts.add(_webGLBlock);
    if (blockWebRtc) parts.add(_webRtcBlock);
    if (spoofTimezone) parts.add(_timezoneSpoof);
    if (blockNavigatorProps) parts.add(_navigatorSpoof);
    parts.add(_screenSpoof);
    parts.add(_pluginsSpoof);
    parts.add(_storageBlock);

    return '''
(function() {
  'use strict';

  ${parts.join('\n\n')}

  console.log('[Osiris] Anti-fingerprinting layer active.');
})();
''';
  }

  /// Inject privacy overrides before page scripts start running.
  ///
  /// On Android versions without WebView document-start script support, the
  /// plugin can only inject this as early as possible.
  static UserScript buildUserScript({
    bool blockCanvas = true,
    bool blockAudio = true,
    bool blockWebGL = true,
    bool blockWebRtc = true,
    bool spoofTimezone = true,
    bool blockNavigatorProps = true,
    bool cookiesEnabled = true,
  }) {
    final source = StringBuffer(buildScript(
      blockCanvas: blockCanvas,
      blockAudio: blockAudio,
      blockWebGL: blockWebGL,
      blockWebRtc: blockWebRtc,
      spoofTimezone: spoofTimezone,
      blockNavigatorProps: blockNavigatorProps,
    ));
    if (!cookiesEnabled) {
      source.write(r'''
      (function() {
        try {
          Object.defineProperty(document, 'cookie', {
            get: function() { return ''; },
            set: function() { return true; },
            configurable: true
          });
        } catch(e) {}
      })();
      ''');
    }

    return UserScript(
      groupName: 'osiris-privacy',
      source: source.toString(),
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: false,
    );
  }

  static const String _canvasBlock = r'''
  // ─── Canvas Fingerprinting Block ─────────────────────────────────────────
  const origGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function(type, ...args) {
    const ctx = origGetContext.call(this, type, ...args);
    if (ctx && (type === '2d' || type === 'webgl' || type === 'webgl2' || type === 'experimental-webgl')) {
      const origToDataURL = this.toDataURL.bind(this);
      const origToBlob = this.toBlob.bind(this);

      // Inject subtle noise into canvas output
      this.toDataURL = function(format, quality) {
        const data = origToDataURL(format, quality);
        // Modify last few characters to break fingerprint
        return data.slice(0, -8) + Math.random().toString(36).substr(2, 8);
      };

      // Intercept ImageData
      if (type === '2d') {
        const origGetImageData = ctx.getImageData.bind(ctx);
        ctx.getImageData = function(sx, sy, sw, sh) {
          const imageData = origGetImageData(sx, sy, sw, sh);
          const data = imageData.data;
          for (let i = 0; i < data.length; i += 4) {
            data[i]     = data[i]     ^ (Math.random() * 2 | 0);
            data[i + 1] = data[i + 1] ^ (Math.random() * 2 | 0);
            data[i + 2] = data[i + 2] ^ (Math.random() * 2 | 0);
          }
          return imageData;
        };
      }
    }
    return ctx;
  };

  // Spoof canvas dimensions to common values
  Object.defineProperties(HTMLCanvasElement.prototype, {
    width:  { get: function() { return this._w || 300; }, set: function(v) { this._w = v; } },
    height: { get: function() { return this._h || 150; }, set: function(v) { this._h = v; } },
  });
''';

  static const String _audioContextBlock = r'''
  // ─── AudioContext Fingerprinting Block ──────────────────────────────────
  const AudioCtx = window.AudioContext || window.webkitAudioContext;
  if (AudioCtx) {
    const origGetChannelData = AudioBuffer.prototype.getChannelData;
    AudioBuffer.prototype.getChannelData = function(channel) {
      const data = origGetChannelData.call(this, channel);
      for (let i = 0; i < data.length; i += 100) {
        data[i] = data[i] + (Math.random() - 0.5) * 0.0001;
      }
      return data;
    };

    const origCreateOscillator = AudioCtx.prototype.createOscillator;
    AudioCtx.prototype.createOscillator = function() {
      const osc = origCreateOscillator.call(this);
      return osc;
    };

    // Spoof sample rate
    Object.defineProperty(AudioCtx.prototype, 'sampleRate', {
      get: function() { return 44100; }
    });
  }
''';

  static const String _webGLBlock = r'''
  // ─── WebGL Fingerprinting Block ───────────────────────────────────────
  const spoofedVendor   = 'Google Inc. (Intel)';
  const spoofedRenderer = 'ANGLE (Intel, Intel(R) UHD Graphics Direct3D11 vs_5_0 ps_5_0, D3D11)';

  const getParamOrig = WebGLRenderingContext.prototype.getParameter;
  WebGLRenderingContext.prototype.getParameter = function(param) {
    if (param === 37445) return spoofedVendor;    // UNMASKED_VENDOR_WEBGL
    if (param === 37446) return spoofedRenderer;  // UNMASKED_RENDERER_WEBGL
    if (param === 7937)  return spoofedVendor;    // VENDOR
    if (param === 7936)  return spoofedRenderer;  // RENDERER
    if (param === 7938)  return 'WebGL 1.0 (OpenGL ES 2.0 Chromium)';
    if (param === 35724) return 'WebGL GLSL ES 1.0 (OpenGL ES GLSL ES 1.0 Chromium)';
    return getParamOrig.call(this, param);
  };

  if (window.WebGL2RenderingContext) {
    const getParam2Orig = WebGL2RenderingContext.prototype.getParameter;
    WebGL2RenderingContext.prototype.getParameter = function(param) {
      if (param === 37445) return spoofedVendor;
      if (param === 37446) return spoofedRenderer;
      if (param === 7937)  return spoofedVendor;
      if (param === 7936)  return spoofedRenderer;
      return getParam2Orig.call(this, param);
    };
  }
''';

  static const String _webRtcBlock = r'''
  // ─── WebRTC Block ──────────────────────────────────────────────────────
  // Override RTCPeerConnection to block IP leaks
  const RTCPeerConnectionOrig = window.RTCPeerConnection ||
                                 window.webkitRTCPeerConnection ||
                                 window.mozRTCPeerConnection;

  if (RTCPeerConnectionOrig) {
    const fakeRTC = function(config, constraints) {
      // Filter out STUN/TURN servers to prevent IP leaks
      if (config && config.iceServers) {
        config.iceServers = [];
      }
      const pc = new RTCPeerConnectionOrig(config, constraints);

      // Override addIceCandidate to block local candidates
      const origAddIce = pc.addIceCandidate.bind(pc);
      pc.addIceCandidate = function(candidate) {
        if (candidate && candidate.candidate) {
          const c = candidate.candidate;
          // Block local IP candidates
          if (c.includes('192.168.') || c.includes('10.') ||
              c.includes('172.16.') || c.includes('127.') ||
              c.includes('169.254.')) {
            return Promise.resolve();
          }
        }
        return origAddIce(candidate);
      };
      return pc;
    };
    fakeRTC.prototype = RTCPeerConnectionOrig.prototype;

    window.RTCPeerConnection = fakeRTC;
    if (window.webkitRTCPeerConnection) window.webkitRTCPeerConnection = fakeRTC;
    if (window.mozRTCPeerConnection) window.mozRTCPeerConnection = fakeRTC;
  }

  // Block MediaDevices enumeration
  if (navigator.mediaDevices && navigator.mediaDevices.enumerateDevices) {
    navigator.mediaDevices.enumerateDevices = function() {
      return Promise.resolve([]);
    };
  }
''';

  static const String _timezoneSpoof = r'''
  // ─── Timezone Spoof ───────────────────────────────────────────────────
  const spoofedTZ = 'UTC';

  const origDateTimeFormat = Intl.DateTimeFormat;
  if (typeof Intl !== 'undefined') {
    const origResolvedOptions = Intl.DateTimeFormat.prototype.resolvedOptions;
    Intl.DateTimeFormat.prototype.resolvedOptions = function() {
      const opts = origResolvedOptions.call(this);
      opts.timeZone = spoofedTZ;
      return opts;
    };
  }

  // Override Date timezone methods
  const origGetTimezoneOffset = Date.prototype.getTimezoneOffset;
  Date.prototype.getTimezoneOffset = function() { return 0; };

  const origToLocaleString = Date.prototype.toLocaleString;
  Date.prototype.toLocaleString = function(...args) {
    if (!args[1]) args[1] = {};
    args[1].timeZone = spoofedTZ;
    return origToLocaleString.apply(this, args);
  };
''';

  static const String _navigatorSpoof = r'''
  // ─── Navigator Spoofing ───────────────────────────────────────────────
  const navigatorProps = {
    platform:        { get: () => 'Win32' },
    hardwareConcurrency: { get: () => 4 },
    deviceMemory:    { get: () => 8 },
    maxTouchPoints:  { get: () => 0 },
    language:        { get: () => 'en-US' },
    languages:       { get: () => Object.freeze(['en-US', 'en']) },
    doNotTrack:      { get: () => '1' },
    webdriver:       { get: () => false },
    connection:      { get: () => ({ effectiveType: '4g', rtt: 50, downlink: 10, saveData: false }) },
  };

  for (const [key, descriptor] of Object.entries(navigatorProps)) {
    try {
      Object.defineProperty(Navigator.prototype, key, descriptor);
    } catch(e) {}
  }
''';

  static const String _screenSpoof = r'''
  // ─── Screen Spoofing ─────────────────────────────────────────────────
  const screenProps = {
    width:       { get: () => 1920 },
    height:      { get: () => 1080 },
    availWidth:  { get: () => 1920 },
    availHeight: { get: () => 1040 },
    colorDepth:  { get: () => 24 },
    pixelDepth:  { get: () => 24 },
  };

  for (const [key, descriptor] of Object.entries(screenProps)) {
    try {
      Object.defineProperty(Screen.prototype, key, descriptor);
    } catch(e) {}
  }

  // devicePixelRatio
  try {
    Object.defineProperty(window, 'devicePixelRatio', { get: () => 1 });
  } catch(e) {}
''';

  static const String _pluginsSpoof = r'''
  // ─── Plugins Spoof (Chrome-like) ──────────────────────────────────────
  const makePlugin = (name, desc, filename, types) => {
    const plugin = Object.create(Plugin.prototype);
    Object.defineProperties(plugin, {
      name:        { value: name, enumerable: true },
      description: { value: desc, enumerable: true },
      filename:    { value: filename, enumerable: true },
      length:      { value: types.length, enumerable: true },
    });
    return plugin;
  };

  try {
    const fakePlugins = [
      makePlugin('PDF Viewer', 'Portable Document Format', 'internal-pdf-viewer', ['application/pdf']),
      makePlugin('Chrome PDF Viewer', 'Portable Document Format', 'internal-pdf-viewer', ['application/pdf']),
      makePlugin('Chromium PDF Viewer', 'Portable Document Format', 'internal-pdf-viewer', ['application/pdf']),
    ];

    Object.defineProperty(navigator, 'plugins', {
      get: () => fakePlugins,
    });
    Object.defineProperty(navigator, 'mimeTypes', {
      get: () => [],
    });
  } catch(e) {}
''';

  static const String _storageBlock = r'''
  // ─── Privacy Cleanup Helpers ──────────────────────────────────────────
  // Expose an Osiris global for app communication
  window.__osiris = {
    version: '1.0',
    privacyActive: true,
    clearSession: function() {
      try { sessionStorage.clear(); } catch(e) {}
      try { localStorage.clear(); } catch(e) {}
      try {
        document.cookie.split(';').forEach(function(c) {
          document.cookie = c.replace(/^ +/, '').replace(/=.*/,
            '=;expires=' + new Date().toUTCString() + ';path=/');
        });
      } catch(e) {}
    }
  };

  // Block battery API (fingerprinting vector)
  if (navigator.getBattery) {
    navigator.getBattery = function() {
      return Promise.resolve({
        charging: true,
        chargingTime: 0,
        dischargingTime: Infinity,
        level: 1.0,
        addEventListener: () => {},
        removeEventListener: () => {},
      });
    };
  }

  // Block performance timing leaks
  if (window.performance && window.performance.timing) {
    const fakeTime = Date.now() - Math.floor(Math.random() * 100000);
    Object.defineProperty(window.performance, 'timeOrigin', {
      get: () => fakeTime,
    });
  }
''';
}
