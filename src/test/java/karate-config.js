function fn() {
  // Settings come from -D system properties, then environment variables, then defaults.
  // DummyJSON's demo login is published on its docs page, so it's a safe default; override for real systems.
  var System = Java.type('java.lang.System');
  function setting(prop, envVar, fallback) {
    return karate.properties[prop] || System.getenv(envVar) || fallback;
  }

  var config = {
    env: karate.env || 'demo',
    baseUrl: setting('base.url', 'BASE_URL', 'https://dummyjson.com'),
    username: setting('api.username', 'API_USERNAME', 'emilys'),
    password: setting('api.password', 'API_PASSWORD', 'emilyspass')
  };

  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 30000);
  // Pretty-print JSON in logs; the HTML report keeps the log only for failed steps.
  karate.configure('logPrettyResponse', true);
  karate.configure('report', { showLog: true, showAllSteps: false });

  return config;
}
