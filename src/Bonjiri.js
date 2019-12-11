exports.run = function(dict) {
  return function(err) {
    return function(succ) {
      return function(promiseSpec) {
        return function() {
          function onSuccess(val) {
            succ(val)();
          }
          function onError(f) {
            err(f)();
          }
          return promiseSpec().then(onSuccess, onError);
        };
      };
    };
  };
};

exports.chain = function(dict) {
  return function(fn) {
    return function(promiseSpec) {
      return function() {
        return promiseSpec().then(function(a) {
          return fn(a)();
        });
      };
    };
  };
};

exports.catch = function(dict) {
  return function(fn) {
    return function(promiseSpec) {
      return function() {
        return promiseSpec().catch(function(a) {
          return fn(a)();
        });
      };
    };
  };
};

exports.resolve = function(dict) {
  return function(a) {
    return function() {
      return Promise.resolve(a);
    };
  };
};

exports.reject = function(a) {
  return function() {
    return Promise.reject(a);
  };
};
