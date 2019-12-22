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

exports.mkPromiseSpec = function(dict) {
  return function(callback) {
    return function() {
      var wrapFn = function(fn) {
        return function(x) {
          return function() {
            return fn(x);
          };
        };
      };
      return new Promise(function(res, rej) {
        var wrappedRes = wrapFn(res);
        var wrappedRej = wrapFn(rej);
        callback(wrappedRes)(wrappedRej)();
      });
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

exports.all = function(dict) {
  return function(specs) {
    return function() {
      return Promise.all(specs.map(spec => spec()));
    };
  };
};

exports.apply = function(dict1) {
  return function(dict2) {
    return function(specFn) {
      return function(specA) {
        return function() {
          return Promise.all([specFn(), specA()]).then(function(xs) {
            return xs[0](xs[1]);
          });
        };
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
